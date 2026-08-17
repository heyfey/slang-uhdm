// v85xA — MACRO BUFFERS.  Every span this law sets is an OFFSET INTO THE
// RECEIVER'S OWN TEXT, so a receiver that comes out of a macro expansion is the
// one input that can put those offsets in a different buffer from the statement.
`define STMTA85  this.q.delete(0)
`define RECVA85  this.q
`define HNDLA85  this
`define MBRA85   q
module v85xa;
  class cav;
    int q[$];
    int n;
    function void f(int k);
      `STMTA85;                    // L13 macro supplies the WHOLE call
      `RECVA85.delete(1);          // L14 macro supplies the RECEIVER
      `HNDLA85.q.delete(2);        // L15 macro supplies the HANDLE only
      this.`MBRA85.delete(3);      // L16 macro supplies the MEMBER only
      this.q.delete(k);            // L17 plain control
      this.n = 0;
    endfunction
  endclass
endmodule
