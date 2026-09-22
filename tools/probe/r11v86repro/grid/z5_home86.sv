// VERIFIER arm z5 — HOMES THAT ARE NEITHER A MODULE NOR A PACKAGE.  The law's
// only home gate is "the pattern's syntax has no PackageDeclaration ancestor",
// so a COMPILATION-UNIT pattern and an INSTANTIATED-INTERFACE pattern both
// pass it.  If either is golden the clone route, the law writes on a cell it
// never measured.
package z5p;
  localparam ZPD = 16'd5;
  localparam ZPO = 16'o5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
  } t;
endpackage
localparam ZUD = 16'd5;
localparam ZUO = 16'o5;
localparam z5p::t ZU = '{bail: 8'hxA, a: ZUD, b: ZUO, c: z5p::ZPD};
interface z5_if;
  localparam ZID = 16'd5;
  localparam ZIO = 16'o5;
  localparam z5p::t ZI = '{bail: 8'hxA, a: ZID, b: ZIO, c: z5p::ZPD};
endinterface
module z5_home86;
  z5_if i0();
  z5_sink #(.R(ZU)) s1();
  localparam ZMD = 16'd5;
  localparam z5p::t ZM = '{bail: 8'hxA, a: ZMD, b: ZUD, c: ZUO};
  z5_sink #(.R(ZM)) s2();
endmodule
module z5_sink #(parameter z5p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
