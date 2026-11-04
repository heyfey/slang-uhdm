// § fwListedQualNameMatch450
package p;
  class port_base #(type IF = int);
    typedef port_base #(IF) this_type;
  endclass
  class sock_base #(type T = int) extends port_base #(T);
  endclass
  class sock #(type T = int) extends sock_base #(T);
    function void connect(this_type provider);
    endfunction
  endclass
  class aaa_registry #(type T = int, string Tname = "x");
    typedef aaa_registry #(T, Tname) this_type;
    static function this_type get();
      return null;
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
