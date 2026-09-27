// § modAggTfArgCloneFollows180 (r11u190: a UNION typedef with a nested struct member and an ENUM typedef, each moved by a formal; localparam copies)
module top(output logic [7:0] o1, output logic [1:0] o2);
  typedef union packed { logic [7:0] w; struct packed { logic [3:0] h; logic [3:0] l; } s; } u_t;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  function automatic logic [7:0] fu(input u_t x); return x.w; endfunction
  function automatic logic [1:0] fe(input e_t x); return x; endfunction
  localparam u_t U = 8'h5A;
  localparam e_t E = E2;
  assign o1 = fu(U);
  assign o2 = fe(E);
endmodule
