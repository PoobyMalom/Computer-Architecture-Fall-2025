
module memory #(
    parameter INIT_FILE = ""
)(
    input logic clk,
    input logic write, // logical flag for writing, always reads
    input logic [5:0] read_address,
    input logic [7:0] write_data,
    output logic [7:0] read_data
);

    reg [7:0] mem [0:63];

    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, mem);
    end

    always_ff @(posedge clk) begin
        if (write) // If write
            mem[read_address] <= write_data; 
        read_data <= mem[read_address];
    end

endmodule
