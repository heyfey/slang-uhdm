// b7_multiline — AXIS 6, the LOCATION residue's mechanism.  a1_witness matched
// golden's spans EXACTLY, so the r10uvm60 head's location difference (golden
// 150:156, ours 149:331) is NOT caused by a two-line macro BODY.  uvm-1.2's real
// site is `uvm_error("UVM/GET_TO_LOCK_DAP/SAG",  <newline>  $sformatf(...))` —
// the macro INVOCATION's ARGUMENTS span source lines.  Rows:
//   L1 invocation on ONE line                      (a1_witness's shape)
//   L2 invocation's arguments span TWO lines
//   L3 invocation's arguments span THREE lines
//   L4 two-line invocation whose second line is itself long
// Every row ends in the same trailing literal `1` on a `bit` formal, so the only
// thing that can move is the reported span.
`define e70(ID, MSG) \
   begin \
     if (chk70(ID)) \
       rep70 (ID, MSG, 0, "", 65, "", 1); \
   end

package p70;
   function bit chk70(string id);
      return 1;
   endfunction
   function void rep70(string id, string message, int verbosity = 0,
                       string filename = "", int line = 0,
                       string context_name = "", bit flag = 0);
   endfunction

   class c70;
      string m_name;
      function string get_full_name();
         return m_name;
      endfunction
      function void set(int value);
         `e70("L1/ID", "one line")
         `e70("L2/ID",
              $sformatf("two lines %s", get_full_name()))
         `e70("L3/ID",
              $sformatf("three lines %s",
                        get_full_name()))
         `e70("L4/ID",
              $sformatf("a considerably longer second line, so that the expanded-buffer column is unmistakable %s", get_full_name()))
      endfunction
   endclass
endpackage
