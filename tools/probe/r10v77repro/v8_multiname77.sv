// r10v77 -- ADVERSARIAL grid H: the SHARED-TYPE-SYNTAX trap.  Several port
// names in ONE declaration item (ANSI and non-ANSI), spelled BARE (imported)
// and SCOPED, so a predicate that reads the port's own type SYNTAX is asked
// what it does for the names that do not carry one.
package h77;
  typedef logic [7:0] v8_t;
  typedef enum logic [1:0] { H770, H771 } e_t;
endpackage

module leafH import h77::*; (
  input  v8_t      h_impa, h_impb,      // BARE imported, two names, one item
  input  h77::v8_t h_pka,  h_pkb,       // SCOPED, two names, one item
  output v8_t      h_impo,
  output h77::v8_t h_pko,
  input  logic [7:0] h_pla, h_plb
);
  assign h_impo = h_impa ^ h_impb;
  assign h_pko  = h_pka  ^ h_pkb;
endmodule

module naH (n_impa, n_impb, n_pka, n_pkb, n_pla);
  import h77::*;
  input  v8_t      n_impa, n_impb;
  input  h77::v8_t n_pka,  n_pkb;
  input  [7:0]     n_pla;
endmodule

module topH;
  logic [7:0] a, b, c, d, e, f, g, h;
  leafH u_h (.h_impa(a), .h_impb(b), .h_pka(c), .h_pkb(d),
             .h_impo(e), .h_pko(f), .h_pla(g), .h_plb(h));
  naH   u_n (.n_impa(a), .n_impb(b), .n_pka(c), .n_pkb(d), .n_pla(g));
endmodule
