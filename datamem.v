`timescale 1ns / 1ps

module datamem(
    input [31:0]address, 
    input [31:0]writeData,
    input MemRead, MemWrite, clk, reset,
    output reg [31:0]readData
    );
    
    reg [31:0]memory[0:127];
    integer i;
    
    
    always @(posedge clk, posedge reset)
    begin
        if (reset)
            begin
                for (i=0; i<128; i=i+1)
                memory[i]<=32'b0;
            end
        else if (MemWrite)
                memory[address[31:2]]<=writeData;            
    end
    
    always @(*) begin
        if (MemRead) 
            readData = memory[address[31:2]];
        else         
            readData = 32'b0;
    end
endmodule
