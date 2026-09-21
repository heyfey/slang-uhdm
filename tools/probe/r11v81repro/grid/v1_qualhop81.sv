// r11v81 adversarial arm v1 — A PACKAGE-HOMED UNTYPED HOP REFERENCED FROM A
// MODULE, qualified and imported.  The law gates on the HOP's home, not the
// pattern's; §2.1 records `pk::BIG` (declared type) as golden NOTHING.
package v1p;
  localparam PU = 5;
  localparam PH = 16'h5;
  localparam PD = 16'd5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
  } t1;
  localparam t1 PKGSIDE = '{bail: 8'hxA, a: PU, b: PH, c: PD};
endpackage
module v1_qualhop81;
  import v1p::*;
  localparam v1p::t1 QM = '{bail: 8'hxA, a: v1p::PU, b: v1p::PH, c: v1p::PD};
  localparam v1p::t1 IM = '{bail: 8'hxA, a: PU, b: PH, c: PD};
  v1_sink #(.R(QM)) s1();
  v1_sink #(.R(IM)) s2();
  v1_sink #(.R(v1p::PKGSIDE)) s3();
endmodule
module v1_sink #(parameter v1p::t1 R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
