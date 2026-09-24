// r11u34 grid u2 — NARROW (<=64b) structs, packed and unpacked, never read.
package p;
  typedef struct { int unsigned A; } uns_t;          // 32b UNPACKED
  typedef struct packed { int unsigned A; } pks_t;   // 32b PACKED
  localparam uns_t UN = '{A:5};
  localparam pks_t PK = '{A:6};
endpackage
module u2 (output logic [31:0] o);
  assign o = 0;
endmodule
