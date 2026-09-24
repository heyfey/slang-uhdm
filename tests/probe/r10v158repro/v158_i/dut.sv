// v158 arm I — ACCEPTED TWINS for every RESHAPE face arm A raised.
// Same generic-class defaults, same locals, but NO rejected statement, so the
// question "did the recovery introduce this residue or inherit it?" is
// answered on the SAME database.
package Wpk2;
  typedef enum bit [2:0] { RED9=1, AMBER9=3, JADE9=6 } tint9_e;
  typedef struct packed { bit [5:0] hi; bit [1:0] lo; } cargo9_s;
  class ferry9;
    int weight;
  endclass

  // default = a CLASS — ACCEPTED block
  class Tok_cls #(type QQ = ferry9);
    function void go();
      if (1) begin
        QQ boat;
        boat = null;
      end
    endfunction
  endclass
  // default = a CLASS — REJECTED block, same declaration
  class Tbad_cls #(type QQ = ferry9);
    function void go();
      if (1) begin
        QQ boat;
        boat = QQ::nonesuch9::create("boat");
      end
    endfunction
  endclass

  // default = a STRUCT — ACCEPTED
  class Tok_str #(type QQ = cargo9_s);
    function void go();
      if (1) begin
        QQ crate;
        crate = 0;
      end
    endfunction
  endclass
  // default = a STRUCT — REJECTED
  class Tbad_str #(type QQ = cargo9_s);
    function void go();
      if (1) begin
        QQ crate;
        crate = QQ::type_id::create("crate");
      end
    endfunction
  endclass

  // default = an ENUM — ACCEPTED
  class Tok_enum #(type QQ = tint9_e);
    function void go();
      if (1) begin
        QQ shade;
        shade = RED9;
      end
    endfunction
  endclass
  // default = an ENUM — REJECTED
  class Tbad_enum #(type QQ = tint9_e);
    function void go();
      if (1) begin
        QQ shade;
        shade = QQ::type_id::create("shade");
      end
    endfunction
  endclass
endpackage

module wtop_i;
  initial begin
    int hold9;
    hold9 = 0;
  end
endmodule
