// § insideSetParamFoldKeepsPa270
package pk;
  localparam logic [3:0] PQ = 4'd6;
  localparam logic [3:0] PR = 4'd7;
endpackage
interface ifc (input logic [3:0] p);
  import pk::*;
  wire w_q = p inside {pk::PQ, 4'd2};
  wire w_b = p inside {PR, 4'd3};
  function automatic bit f(logic [3:0] v);
    return v inside {pk::PQ, PR};
  endfunction
endinterface
module dut (input logic [3:0] p, output logic o, output logic o2);
  ifc u_if (.p(p));
  assign o = u_if.w_q;
  assign o2 = u_if.w_b;
endmodule
