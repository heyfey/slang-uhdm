// pz20.sv — PASS 20 witness for the prim_keccak pair (def r=32 at
// prim_keccak.sv:24:28 and Top r=32 at :52:5), the "when does the view keep
// the bound SYMBOLIC" family.  The def-view bisect lands on
//   cont_assign :37:10 > func_call bitarray_to_box > function > logic_var
//     > ref_typespec > logic_typespec 'box_t' :24:11 > Ranges[2] > Left_expr
// where golden keeps `operation {op=11}` (the symbolic `W-1`) and we fold it
// to `constant 63`.  W is a LOCALPARAM declared in the parameter list.
module pz20 #(
    parameter  int Width = 1600,
    localparam int W     = Width / 25
) (
    input        [Width-1:0] s_i,
    output logic [Width-1:0] s_o
);

  typedef logic [4:0][4:0][W-1:0] box_t;

  box_t state_in;

  function automatic box_t bitarray_to_box(input logic [Width-1:0] a);
    box_t box;
    box[0][0][0] = a[0];
    return box;
  endfunction

  // A FORMAL typed by the same module typedef — prim_keccak's `theta(box_t
  // state)`.  § tfFormalTs says a formal's own range FOLDS like a module one;
  // a formal typed by a TYPEDEF is the case that law never saw.
  function automatic logic theta(input box_t st);
    return st[0][0][0];
  endfunction

  // ...and a formal that writes its OWN range, the § tfFormalTs shape.
  function automatic logic phi(input logic [W-1:0] v);
    return v[0];
  endfunction

  assign state_in = bitarray_to_box(s_i);
  assign s_o      = {Width{theta(state_in) ^ phi(state_in[0][0])}};

endmodule
