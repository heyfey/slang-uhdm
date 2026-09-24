// r10earl29 GRID arm b2 — element kinds the a1/a2 grid did not cover, plus the
// NON-CONCAT index kinds that decide between the two candidate models of the
// suffix rule:
//   model A  the whole `[...]` suffix is built by decompileHelper(bit_select),
//            which knows ONLY constant / ref_obj / operation indices and returns
//            the EMPTY STRING (no brackets at all) for every other index kind;
//   model B  the caller always writes brackets and fills them with
//            prettyPrint(index), which DOES render var_select and part_select.
// A var_select index (`m[1][2]`, no dot, two selects) separates them: model A
// drops the suffix, model B renders `[m[1][2]]`.
module b2_kinds (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4,
    output logic       o5,
    output logic       o6,
    output logic       o7,
    output logic       o8
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  typedef struct packed {logic [3:0] addr;} req_t;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  localparam logic [1:0] P = 2'd2;
  st_t  q;
  req_t rq;
  logic [1:0][3:0] m;
  logic [3:0] k;
  e_t   ev;
  always_comb begin
    o1 = q.autoexecprogbuf[m[1][2]];        // NON-concat, var_select index
    o2 = q.autoexecprogbuf[w[2]];           // NON-concat, bit_select index
    o3 = q.autoexecprogbuf[{1'b1, P}];      // concat with a localparam element
    o4 = q.autoexecprogbuf[{1'b1, E1}];     // concat with an enum-literal element
    o5 = q.autoexecprogbuf[{1'b1, ev}];     // concat with an enum-VAR element
    o6 = q.autoexecprogbuf[{1'b1, k[1:0]+1'b1}];  // concat with arithmetic
    o7 = q.autoexecprogbuf[{1'b1, ~k[0]}];  // concat with a unary op
    o8 = q.autoexecprogbuf[{1'b1, k[0] ? 1'b1 : 1'b0}]; // concat with a ternary
  end
endmodule
