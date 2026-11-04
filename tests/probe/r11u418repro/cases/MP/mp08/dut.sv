// § modportImplicitHdrNoNetType418
interface input_if(input clk);
    logic [7:0] data;
endinterface
module dut(input_if in, output logic [7:0] o);
    always @(posedge in.clk) o <= in.data;
endmodule
module top;
    logic clk;
    logic [7:0] o;
    input_if in(clk);
    dut d(in, o);
endmodule
