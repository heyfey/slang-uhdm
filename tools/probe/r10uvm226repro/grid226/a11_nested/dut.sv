// arm a11: the MiniAmiq SHAPE, reduced.  An uninstantiated interface whose one
// `initial` block is the LAST kind the corpus actually contains: a named-block
// automatic local, a $sformatf chain over it, a macro-free call into the
// interface's own DPI-import function, and an if/else over a method call on a
// package class handle.  This is the arm that must answer for the corpus row.
package p226n;
   class c226n;
      static c226n inst226;
      function int verbosity226(); return 3; endfunction
      static function c226n get226(); return inst226; endfunction
   endclass
   c226n top226n = c226n::get226();
endpackage

interface if226_n();
   import p226n::*;

   string test_name226;
   int    handles226 [];

   import "DPI-C" context function void register226(int a226);

   initial begin
      automatic string hdr226 = "\n----------------";
      hdr226 = $sformatf("%s\n\t\t%s\n", hdr226, "V1.0");
      hdr226 = $sformatf("%s----------------\n", hdr226);
      $display("%s", hdr226);
      if (top226n.verbosity226() >= 2)
         register226(1);
      else
         register226(0);
   end

   function void set_name226(string a_name226);
      test_name226 = a_name226;
   endfunction
endinterface

module top226_n;
   logic unused226;
endmodule
