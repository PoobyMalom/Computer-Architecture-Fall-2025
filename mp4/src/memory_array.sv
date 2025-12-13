module memory_array #(
    parameter INIT_FILE = ""
)(
    input logic     clk, 
    input logic     write_enable, 
    input logic     [9:0] address, 
    input logic     [7:0] data_in, 
    output logic    [7:0] data_out
);

    logic [7:0] memory [0:1023];

    int i;

    // Initialize memory array
    initial begin
        if (INIT_FILE) begin
            $readmemh(INIT_FILE, memory);
        end
        else begin
            for (i = 0; i < 1023; i++) begin
                memory[i] = 8'd0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (write_enable) begin
            memory[address] <= data_in;
        end
        else begin
            data_out <= memory[address];
        end
    end

endmodule
