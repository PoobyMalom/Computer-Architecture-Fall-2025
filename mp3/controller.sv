
module controller (
    input logic clk, 
    input logic finished_calculating, 
    output logic start_next_game_state,
    output logic load_sreg, 
    output logic transmit_pixel, 
    output logic [5:0] pixel
);

    localparam TRANSMIT_FRAME       = 2'b00;
    localparam IDLE                 = 2'b01;
    localparam CALC                 = 2'b10;

    localparam [2:0] READ_CH_VALS   = 3'b001;
    localparam [2:0] LOAD_SREG      = 3'b010;
    localparam [2:0] TRANSMIT_PIXEL = 3'b100;

    localparam [8:0] TRANSMIT_CYCLES    = 9'd360;       // = 24 bits / pixel x 15 cycles / bit
    localparam [23:0] IDLE_CYCLES       = 24'd12000000;

    logic [1:0] state = TRANSMIT_FRAME;
    logic [1:0] next_state;

    logic [2:0] transmit_phase = READ_CH_VALS;
    logic [2:0] next_transmit_phase;

    logic [5:0] pixel_counter = 6'd0;
    logic [8:0] transmit_counter = 9'd0;
    logic [23:0] idle_counter = 24'd0;

    logic transmit_pixel_done;
    logic idle_done;

    assign transmit_pixel_done = (transmit_counter == TRANSMIT_CYCLES - 1);
    assign idle_done = (idle_counter == IDLE_CYCLES - 1);
    assign start_next_game_state = (next_state == CALC);

    always_ff @(posedge clk) begin
        state <= next_state;
        transmit_phase <= next_transmit_phase;
    end

    always_comb begin
        next_state = 2'bx;
        unique case (state)
            TRANSMIT_FRAME:
                if ((pixel_counter == 6'd0) && (transmit_pixel_done))
                    next_state = CALC;
                else
                    next_state = TRANSMIT_FRAME;
            CALC:
                if (finished_calculating)
                    next_state = IDLE;
                else 
                    next_state = CALC;
            IDLE:
                if (idle_done)
                    next_state = TRANSMIT_FRAME;
                else
                    next_state = IDLE;
        endcase
    end

    always_comb begin
        next_transmit_phase = READ_CH_VALS;
        if (state == TRANSMIT_FRAME) begin
            case (transmit_phase)
                READ_CH_VALS:
                    next_transmit_phase = LOAD_SREG;
                LOAD_SREG:
                    next_transmit_phase = TRANSMIT_PIXEL;
                TRANSMIT_PIXEL:
                    next_transmit_phase = transmit_pixel_done ? READ_CH_VALS : TRANSMIT_PIXEL;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if ((state == TRANSMIT_FRAME) && transmit_pixel_done) begin
            pixel_counter <= pixel_counter + 1;
        end
    end

    always_ff @(posedge clk) begin
        if (transmit_phase == TRANSMIT_PIXEL) begin
            transmit_counter <= transmit_counter + 1;
        end
        else begin
            transmit_counter <= 9'd0;
        end
    end

    always_ff @(posedge clk) begin
        if (state == IDLE) begin
            idle_counter <= idle_counter + 1;
        end
        else begin
            idle_counter <= 23'd0;
        end
    end

    assign pixel = pixel_counter;

    assign load_sreg = (transmit_phase == LOAD_SREG);
    assign transmit_pixel = (transmit_phase == TRANSMIT_PIXEL);

endmodule
