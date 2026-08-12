// r10earl29 GRID arm b1 — the SAME concatenation index at the OTHER hier_path
// name-building sites in our emitter, so the law is applied where golden applies
// it and NOWHERE ELSE.  Our emitter builds a hier_path name in (at least) four
// places and they do not share a renderer:
//   s1  member-select, single dim, NamedValue base       (ExprEmit ~10567)
//   s2  member-select followed by a FURTHER MEMBER       (emitMixedHierPath ~2347)
//   s3  BASE array select followed by a member           (emitMixedHierPath ~2309)
//   s4  member-select with TWO selects (var_select last) (ExprEmit ~10682)
module b1_sites (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4
);
  typedef struct packed {logic [3:0] addr;} req_t;
  typedef struct packed {logic [7:0] fld;} el_t;
  typedef struct packed {el_t [3:0] arr;} out_t;
  typedef struct packed {logic [3:0][7:0] g;} s2_t;
  req_t rq;
  out_t t;
  s2_t  z;
  el_t [3:0] ea;
  logic [1:0] k;
  always_comb begin
    o1 = z.g[{1'b0, k[0]}][3];            // s4: member + TWO selects
    o2 = t.arr[{1'b0, k[0]}].fld[0];      // s2: member-select + further member
    o3 = ea[{1'b0, k[0]}].fld[0];         // s3: BASE select + member
    o4 = z.g[{1'b0, rq.addr[0]}][3];      // s4 with an EMPTY-rendering element
  end
endmodule
