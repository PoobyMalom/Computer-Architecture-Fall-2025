// Cycle

module cycle #(
    parameter INC_DEC_INTERVAL = 12000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 300,            // Transition to next state after 300 increments / decrements, which is 0.33s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX,
    parameter START_STATE = 0
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value
);

    // Define state variable values
    localparam PWM_INC = 3'b000;
    localparam PWM_DEC = 3'b001;
    localparam PWM_HLD_HI1 = 3'b010;
    localparam PWM_HLD_HI2 = 3'b011;
    localparam PWM_HLD_LOW1 = 3'b100;
    localparam PWM_HLD_LOW2 = 3'b101;

    // Declare state variables
    logic [2:0] current_state;
    logic [2:0] next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        // Sets PWM high if starting in HLD HI
        if (START_STATE == PWM_HLD_HI1 || START_STATE == PWM_HLD_HI2) begin
            pwm_value = 1200;
        end else begin
            pwm_value = 0;
        end
        current_state = START_STATE;  // Initialize the state machine
    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition)
        current_state <= next_state;

    // Compute the next state of the FSM
    always_comb begin
        next_state = 3'bx;
        case (current_state)
            PWM_INC:
                next_state = PWM_HLD_HI1;
            PWM_HLD_HI1:
                next_state = PWM_HLD_HI2;
            PWM_HLD_HI2:
                next_state = PWM_DEC;
            PWM_DEC:
                next_state = PWM_HLD_LOW1;
            PWM_HLD_LOW1:
                next_state = PWM_HLD_LOW2;
            PWM_HLD_LOW2:
                next_state = PWM_INC;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            PWM_INC:
                pwm_value <= pwm_value + INC_DEC_VAL;
            PWM_DEC:
                pwm_value <= pwm_value - INC_DEC_VAL;
            PWM_HLD_HI1:
                pwm_value <= pwm_value;
            PWM_HLD_HI2:
                pwm_value <= pwm_value;
            PWM_HLD_LOW1:
                pwm_value <= pwm_value;
            PWM_HLD_LOW2:
                pwm_value <= pwm_value;
        endcase
    end

    // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
