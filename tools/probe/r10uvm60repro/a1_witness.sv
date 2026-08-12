// a1_witness — the r10uvm60 head, minimally.
// A macro whose BODY SPANS TWO LINES, whose innermost call passes a BARE
// DECIMAL LITERAL `1` to a `bit` formal, invoked from a CLASS METHOD inside a
// PACKAGE.  This is uvm-1.2's `uvm_error -> uvm_report_error(..., "", 1) shape
// with everything else removed.
`define e60(ID, MSG) \
   begin \
     if (chk60(ID)) \
       rep60 (ID, MSG, 0, "", 65, "", 1); \
   end

package p60;

   function bit chk60(string id);
      return 1;
   endfunction

   function void rep60(string id,
                       string message,
                       int verbosity = 0,
                       string filename = "",
                       int line = 0,
                       string context_name = "",
                       bit report_enabled_checked = 0);
   endfunction

   class c60;
      int m_value;
      function void set(int value);
         `e60("ID/SAG", "message text")
         m_value = value;
      endfunction
   endclass

endpackage
