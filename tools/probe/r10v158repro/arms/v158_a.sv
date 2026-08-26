// v158 arm A — WHAT THE LOCAL IS.  Each rejected begin holds ONE face.
// LHS is always golden.  Names deliberately unlike the implementer's.
package Wpk;

  typedef enum bit [2:0] { RED9=1, AMBER9=3, JADE9=6 } tint9_e;
  typedef struct packed { bit [5:0] hi; bit [1:0] lo; } cargo9_s;

  class ferry9;
    int weight;
    function string tag();  return "ferry"; endfunction
  endclass

  // default = int  (rejected: ::type_id on an int)
  class Kdef_int #(type QQ = int);
    function void go();
      if (1) begin
        QQ solo;
        solo = QQ::type_id::create("solo");
      end
    endfunction
  endclass

  // default = a CLASS
  class Kdef_cls #(type QQ = ferry9);
    function void go();
      if (1) begin
        QQ boat;
        boat = QQ::nonesuch9::create("boat");
      end
    endfunction
  endclass

  // default = a STRUCT
  class Kdef_str #(type QQ = cargo9_s);
    function void go();
      if (1) begin
        QQ crate;
        crate = QQ::type_id::create("crate");
      end
    endfunction
  endclass

  // default = an ENUM
  class Kdef_enum #(type QQ = tint9_e);
    function void go();
      if (1) begin
        QQ shade;
        shade = QQ::type_id::create("shade");
      end
    endfunction
  endclass

  // a TYPEDEF of the parameter
  class Kdef_td #(type QQ = int);
    typedef QQ alias9_t;
    function void go();
      if (1) begin
        alias9_t mirror;
        mirror = QQ::type_id::create("mirror");
      end
    endfunction
  endclass

  // an ARRAY of the parameter type, and a QUEUE of it
  class Kdef_arr #(type QQ = int);
    function void go();
      if (1) begin
        QQ shelf [3];
        QQ line9 [$];
        shelf[0] = QQ::type_id::create("shelf");
      end
    endfunction
  endclass

  // ACCEPTED TWIN — same declaration set, no rejected statement.
  class Kok #(type QQ = int);
    typedef QQ alias9_t;
    function void go();
      if (1) begin
        QQ solo;
        alias9_t mirror;
        QQ shelf [3];
        QQ line9 [$];
        solo = 0;
      end
    endfunction
  endclass

endpackage

module wtop_a;
  initial begin
    int keeper;
    keeper = 7;
  end
endmodule
