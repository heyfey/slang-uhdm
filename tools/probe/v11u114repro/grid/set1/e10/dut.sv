// case item in a package function (not a module)
package pk; parameter logic [7:0] P = {4'h7, 4'h3};
  function automatic logic [3:0] f(input logic [7:0] v);
    case (v) P: return 4'd1; default: return 4'd0; endcase
  endfunction
endpackage
package pk3; import pk::*;
  function automatic logic [3:0] g(input logic [7:0] v);
    case (v) P: return 4'd1; default: return 4'd0; endcase
  endfunction
endpackage
module top (input logic [7:0] x, output logic [3:0] y); assign y = pk3::g(x) ^ pk::f(x); endmodule
