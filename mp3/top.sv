`include "memory.sv"
`include "ws2812b.sv"
`include "controller.sv"
`include "game_updater.sv"
`include "game.sv"

// led_matrix top level module

module top(
    input logic     clk, 
    output logic    _48b, 
    output logic    _45a
);

    logic [7:0] white_data;
    logic [7:0] next_state_data;
    logic done_calculating;
    logic start_calculating;

    logic [5:0] game_address;
    logic [5:0] matrix_address;
    logic [5:0] address;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;
    logic write;

    // Instance sample memory for blue channel
    memory #(
        .INIT_FILE      ("states/white.txt")
    ) u3 (
        .clk            (clk), 
        .write          (write),
        .read_address   (address), 
        .write_data     (next_state_data),
        .read_data      (white_data)
    );

    updater updater (
        .clk                    (clk),
        .start_next_game_state  (start_calculating),
        .cell_state             (white_data),
        .done_writing           (done_calculating),
        .address                (game_address),
        .next_cell_state        (next_state_data),
        .start_writing          (write)
    );

    controller u5 (
        .clk                    (clk), 
        .finished_calculating   (done_calculating),
        .start_next_game_state  (start_calculating),
        .load_sreg              (load_sreg), 
        .transmit_pixel         (transmit_pixel), 
        .pixel                  (matrix_address)
    );

    assign address = !start_calculating ? matrix_address : game_address;

    // Instance the WS2812B output driver
    ws2812b matrix (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    always_ff @(posedge clk) begin
        if (load_sreg) begin
          shift_reg <= {white_data, white_data, white_data};
        end
        else if (shift) begin
          shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
