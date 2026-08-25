// r10uvm147 VERIFIER grid Y — WHERE does golden use the SPLIT element shape
// (bit_select @MID + an anonymous trailing part_select) for the SAME written
// chain?  Grid S found golden splits a parameter-base chain in a LOCALPARAM
// INITIALIZER but fuses it into one var_select in a procedural statement.
package q147vy;
  typedef struct { logic [63:0] arr[4]; } sy147_t;
  localparam sy147_t PY = '{arr:'{64'h1122334455667788, 64'h2, 64'h3, 64'h4}};
  localparam logic [7:0] Y1 = PY.arr[0][15:8];          // y01 localparam init
  function automatic logic [7:0] fy(logic [7:0] dflt = PY.arr[0][15:8]);  // y02 default arg
    return dflt;
  endfunction
endpackage

module m147y;
  import q147vy::*;
  localparam logic [7:0] Y2 = PY.arr[1][15:8];          // y03 module localparam init
  logic [7:0] vinit = PY.arr[0][15:8];                  // y04 VARIABLE initializer
  logic [7:0] o;
  int i;
  initial begin
    o = PY.arr[0][15:8];                                // y05 procedural
    case (i)
      PY.arr[0][15:8]: o = 8'h1;                        // y06 CASE ITEM (const ctx)
      default: o = 8'h2;
    endcase
  end
  if (PY.arr[0][15:8] == 8'h44) begin : gy              // y07 generate condition
    logic [7:0] gsig;
  end
endmodule
