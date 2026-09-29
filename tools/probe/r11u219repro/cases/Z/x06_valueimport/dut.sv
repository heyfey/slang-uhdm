// § enumPkgWriterImportsType219 — packages importing only an enum value, a function or a net of the home package write nothing (v11u84's v3 shape)
package eh1;
  wire  [7:0] x_net;
  function automatic int xf(input int a); return a + 1; endfunction
  typedef enum logic [1:0] {XE0, XE1} xe_t;
endpackage
package ep_fn;  import eh1::xf;   wire [7:0] o1; endpackage
package ep_ev;  import eh1::XE1;  wire [7:0] o4; endpackage
package ep_ty;  import eh1::xe_t; wire [7:0] o5; endpackage
module dut (output logic [31:0] o);
  import eh1::x_net;
  assign o = {24'd0, x_net};
endmodule
