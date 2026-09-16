// r11u49 arm a3 -- KEY KINDS on an unpacked-struct package localparam:
// positional, named, default:, a TYPE key, and named+default mixed.
package p;
  typedef struct { int A; int B; int C; } u3_t;
  localparam u3_t KPOS = '{1, 2, 3};
  localparam u3_t KNAM = '{A:1, B:2, C:3};
  localparam u3_t KDEF = '{default: 7};
  localparam u3_t KTYP = '{int: 9};
  localparam u3_t KMIX = '{A:1, default: 4};
endpackage
module a3 (output logic [31:0] o);
  assign o = p::KPOS.A + p::KNAM.B + p::KDEF.C + p::KTYP.A + p::KMIX.B;
endmodule
