// v11u74 v2 — LAW B, NAMESAKES THAT ARE NOT SIGNALS.  The patch resolves a
// Port through its internalSymbol and declines anything that is not a
// Variable or a Net.  Golden may bind some of these anyway (a name bind does
// not know what kind the object is).
module sub (output logic [31:0] q);
  assign q = 32'd0;
endmodule

module dut (output logic [31:0] o);
  function automatic int unsigned fn(input int unsigned a);
    return a + 1;
  endfunction
  typedef logic [3:0] td;
  localparam int PP = 3;
  logic [31:0] iq;
  sub u_inst (.q(iq));
  logic [31:0] arr [0:1];          // UNPACKED ARRAY namesake
  struct packed { logic [15:0] a; logic [15:0] b; } st;  // struct namesake
  for (genvar i = 0; i < 1; i = i + 1) begin : gb
    logic [31:0] fn;      assign fn = 32'd1;      // namesake of a FUNCTION
    logic [31:0] td;      assign td = 32'd1;      // namesake of a TYPEDEF
    logic [31:0] u_inst;  assign u_inst = 32'd1;  // namesake of an INSTANCE
    logic [31:0] gb;      assign gb = 32'd1;      // namesake of THIS BLOCK
    logic [31:0] arr;     assign arr = 32'd1;     // namesake of an unpacked arr
    logic [31:0] st;      assign st = 32'd1;      // namesake of a struct var
  end
  assign o = gb[0].fn ^ gb[0].td ^ gb[0].u_inst ^ gb[0].gb ^ gb[0].arr
           ^ gb[0].st ^ iq ^ arr[0] ^ st ^ 32'(PP);
endmodule
