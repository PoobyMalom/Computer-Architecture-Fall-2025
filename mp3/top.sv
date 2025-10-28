`include "memory.sv"
`include "ws2812b.sv"
`include "controller.sv"
`include "game_updater.sv"
`include "game.sv"

module top(
    input logic     clk, 
    output logic    _48b, 
    output logic    _45a
);

    logic [7:0] red_data;
    logic [7:0] green_data;
    logic [7:0] blue_data;

    logic [7:0] red_data_next;
    logic [7:0] green_data_next;
    logic [7:0] blue_data_next;

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

    logic address_select; 

    always_ff @(posedge clk) begin
    if (start_calculating)
        address_select <= 1'b1;
    else if (done_calculating)
        address_select <= 1'b0;
    end

    // Instance memory for red channel
    memory #(
        .INIT_FILE      ("states/line.txt")
    ) mem_red (
        .clk            (clk), 
        .write          (write),
        .read_address   (address), 
        .write_data     (red_data_next),
        .read_data      (red_data)
    );

    // Instance game logic for red channel
    updater updater_red (
        .clk                    (clk),
        .start_next_game_state  (start_calculating),
        .cell_state             (red_data),
        .next_cell_state        (red_data_next)
    );

    // Instance memory for green channel
    memory #(
        .INIT_FILE      ("states/glider.txt")
    ) mem_green (
        .clk            (clk), 
        .write          (write),
        .read_address   (address), 
        .write_data     (green_data_next),
        .read_data      (green_data)
    );

    // Instance game logic for green channel
    updater updater_green (
        .clk                    (clk),
        .start_next_game_state  (start_calculating),
        .cell_state             (green_data),
        .next_cell_state        (green_data_next)
    );

    // Instance memory for blue channel
    memory #(
        .INIT_FILE      ("states/mwss.txt")
    ) mem_blue (
        .clk            (clk), 
        .write          (write),
        .read_address   (address), 
        .write_data     (blue_data_next),
        .read_data      (blue_data)
    );

    // Instance game logic for blue channel
    updater updater_blue (
        .clk                    (clk),
        .start_next_game_state  (start_calculating),
        .cell_state             (blue_data),
        .done_writing           (done_calculating),
        .address                (game_address),
        .next_cell_state        (blue_data_next),
        .write                  (write)
    );

    // Instance led matrix controller
    controller u5 (
        .clk                    (clk), 
        .finished_calculating   (done_calculating),
        .start_next_game_state  (start_calculating),
        .load_sreg              (load_sreg), 
        .transmit_pixel         (transmit_pixel), 
        .pixel                  (matrix_address)
    );

    assign address = address_select ? game_address : matrix_address;

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
          shift_reg <= {red_data, green_data, blue_data};
        end
        else if (shift) begin
          shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
