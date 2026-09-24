// a6 — CONTAINER = CLASS.  A class (not a module, not the package) imports the
// specialisation, matching the SimpleUVM (`class_defn work@env`) and Scoreboard
// (`class_defn work@my_scoreboard`) corpus shapes.  Read the ref_typespec
// fullname prefix here for the third cell of rule (4).
package p49f;

  class gc49 #(type KEY = int, type T = int);
    int k;
  endclass

  typedef gc49#(string, int) zzz_first_t;
  typedef gc49#(string, int) aaa_second_t;

endpackage

import p49f::*;

class a6_holder;
  zzz_first_t hz;
  aaa_second_t ha;
endclass

module a6_top;
  a6_holder h;
endmodule
