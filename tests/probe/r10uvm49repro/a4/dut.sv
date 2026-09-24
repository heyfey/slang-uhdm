// a4 — GENUINELY DIFFERENT SPECIALISATIONS, plus the SINGLE-TYPEDEF cell.
//   diff_a_t = gc49#(string,int)   and   diff_b_t = gc49#(int,string)
// are NOT the same specialisation.  Does each get its OWN base class_typespec,
// and is there a vpiTypedefAlias at all?
//   lonely_t is a specialisation with NO sibling typedef: is there a
// vpiTypedefAlias pointing at ITSELF, or none?
package p49d;

  class gc49 #(type KEY = int, type T = int);
    int k;
  endclass

  class other49 #(type KEY = int);
    int k;
  endclass

  typedef gc49#(string, int) diff_a_t;
  typedef gc49#(int, string) diff_b_t;
  typedef other49#(string)   lonely_t;

  class holder49;
    diff_a_t ha;
    diff_b_t hb;
    lonely_t hl;
  endclass

endpackage

module a4_top;
  import p49d::*;
  diff_a_t ma;
endmodule
