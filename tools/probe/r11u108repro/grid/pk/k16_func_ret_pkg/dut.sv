package p;
  localparam int N = 3;
  typedef logic [3:0] v_t;
  typedef logic [0:N-1] vn_t;
  typedef logic s_t;
endpackage
module dut (output logic [2:0] o);
  function automatic p::vn_t f(input logic [2:0] i);
    return i;
  endfunction
  assign o = f(3'b011);
endmodule
