// r11u49 arm b3 -- the TYPE-KEY and POSITIONAL shapes, PACKED and UNPACKED
// side by side, all scoped-read from the module.  (Surelog's parser rejects a
// type key written with a packed range, so the packed type key uses a named
// typedef.)
package p;
  typedef logic [7:0] byte_t;
  typedef struct packed { byte_t A; byte_t B; } pk_t;
  typedef struct        { int A;    int B;    } un_t;
  localparam pk_t PPOS = '{8'd1, 8'd2};      // packed,   positional
  localparam un_t UPOS = '{1, 2};            // unpacked, positional
  localparam pk_t PTYP = '{byte_t: 8'd3};    // packed,   type key
  localparam un_t UTYP = '{int: 4};          // unpacked, type key
  localparam pk_t PDEF = '{default: 8'd5};   // packed,   default key
  localparam un_t UDEF = '{default: 6};      // unpacked, default key
endpackage
module b3 (output logic [31:0] o);
  assign o = p::PPOS.B + p::UPOS.B + p::PTYP.A + p::UTYP.A + p::PDEF.B + p::UDEF.B;
endmodule
