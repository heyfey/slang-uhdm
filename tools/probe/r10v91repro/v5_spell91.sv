// r10v91 arm 5 — EXOTIC TARGET SPELLINGS: struct members, typedef chains,
// type parameters, package/port homes.  Each is a place where slang says
// FixedSizeUnpackedArrayType but Surelog may still fill Elem_typespec.
package p5;
  typedef logic [11:0] wd_t;
  typedef logic [11:0] wa_t [2];
  typedef wa_t          wb_t;                 // typedef OF a typedef
  typedef struct { logic [11:0] arr [2]; logic [11:0] s; } us_t;  // UNPACKED struct
  typedef logic [11:0] pa_t [2];
endpackage

module inner5 (output logic [11:0] po [2], input logic [11:0] d);
  assign po = '{d, 12'd1};                    // assign to an OUTPUT PORT (inline unpacked)
endmodule

module inner5t (output p5::wa_t po, input logic [11:0] d);
  assign po = '{d, 12'd1};                    // assign to an OUTPUT PORT (typedef'd)
endmodule

module v5_spell91 #(parameter type T = p5::wa_t, parameter int NH = 2)
  (input logic [11:0] din, output logic [11:0] q);
  logic [11:0] v12; assign v12 = din;

  // A: unpacked STRUCT member that is an inline unpacked array
  p5::us_t s1;
  assign s1.arr = '{v12, din};
  assign s1.s   = din;

  // B: typedef OF a typedef (still an alias in slang)
  p5::wb_t b1;  assign b1 = '{v12, din};

  // C: a TYPE PARAMETER target
  T c1;         assign c1 = '{v12, din};

  // D: package typedef, package-qualified spelling
  p5::pa_t d1;  assign d1 = '{v12, din};

  // E: an INLINE unpacked array declared in a PORT of a submodule
  logic [11:0] e1 [2];
  inner5  ui  (.po(e1), .d(din));
  p5::wa_t e2;
  inner5t uit (.po(e2), .d(din));

  // F: an unpacked array of an unpacked STRUCT
  p5::us_t f1 [2];
  assign f1 = '{s1, s1};

  // G: inline unpacked array with a typedef'd element AND a packed dim
  p5::wd_t [1:0] g1 [2];
  assign g1 = '{{v12,din}, {din,v12}};

  // H: an unpacked array assigned from a REPLICATION of one element
  logic [11:0] h1 [2];
  assign h1 = '{2{v12}};

  // I: a 3-element pattern where op0 is WIDER than the element
  logic [3:0] i1 [3];
  assign i1 = '{din, din[1:0], 4'd3};

  assign q = s1.arr[0]^b1[0]^c1[0]^d1[0]^e1[0]^e2[0]^f1[0].s^g1[0][0]^h1[0]^{8'd0,i1[0]};
endmodule
