
module memory #(
    parameter INIT_FILE = ""
)(
    input logic clk,
    input logic write,
    input logic [5:0] read_address,
    input logic [7:0] write_data,
    output logic [7:0] read_data
);

    reg [7:0] mem [0:63];

    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, mem);
    end

    always_ff @(negedge clk) begin
        if (write) begin
            mem[read_address] <= write_data; 
        end else begin
            read_data <= mem[read_address];
        end
    end

endmodule
