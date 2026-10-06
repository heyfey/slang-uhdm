// § genIpsBoundOwner256 (a class with this. paths, an extern and a pure virtual prototype beside a for-generate select)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
endpackage
virtual class base; pure virtual function int g(); endclass
class c extends base;
  logic [7:0] x;
  extern function int h();
  function int g(); return this.x[fp::FW +: fp::PW]; endfunction
endclass
function int c::h(); return this.x[1 +: 2]; endfunction
module m import fp::*; (input logic [7:0] a, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : gb
    assign o[i] = |a[FW +: PW];
  end
endmodule
module top(input logic [7:0] a, output logic [3:0] o); m u (.*); endmodule
