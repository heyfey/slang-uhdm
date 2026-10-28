// § fwListedQualNameMatch450
package p;
  class aaa_registry #(type T = int, string Tname = "x");
    typedef aaa_registry #(T, Tname) this_type;
    static function this_type get();
      return null;
    endfunction
    function void set(this_type o);
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class comp;
    typedef aaa_registry #(comp, "comp") type_id;
  endclass
endpackage
module top;
  import q::*;
endmodule
