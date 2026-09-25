// § hpElemSelNameIsPathSoFar154
package ip; typedef struct packed { logic [7:0] adr; logic [7:0] dat; } req_t; endpackage
interface tif; ip::req_t req_dly [3]; modport rd(input req_dly); endinterface
module m(tif.rd bus, input logic clk, output logic [3:0] o);
  always_ff @(posedge clk) o <= bus.req_dly[2].dat[7:4];
endmodule
module top(input logic clk, output logic [3:0] o); tif b(); m u(.bus(b), .clk(clk), .o(o)); endmodule
