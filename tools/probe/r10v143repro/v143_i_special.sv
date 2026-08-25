// r10v143 arm I — the faces the formal/home/index grids cannot carry:
// foreach (the ref_var cell the law MUST NOT touch), a constraint, a class
// PROPERTY INITIALISER, a fork block, a DPI import, extern-prototype default
// placement, `super.`, a class PARAMETER index, and a covergroup.
package pkI143v;
  class Cog; int tally; int gauge; endclass
  parameter int IP_SLOT = 1;

  import "DPI-C" function int dpiPick(input int a);

  class IBase;
    Cog tbl[int];
    int mote;
    task ibase_tk(int k = 0);
      if (tbl[k].tally == 0) $display("ibase");
    endtask
  endclass

  class ISuper extends IBase;
    task isup_tk(int k = 0);
      if (tbl[super.mote].tally == 0) $display("isup_a");
      if (tbl[k].gauge == 0) $display("isup_b");
    endtask
  endclass

  // extern prototype CARRIES the default; the definition repeats it
  class IP1;
    Cog tbl[int];
    extern task ip1(int k = 0);
  endclass
  task IP1::ip1(int k = 0);
    if (tbl[k].tally == 0) $display("ip1");
  endtask

  // extern prototype carries NO default (neither does the definition)
  class IP2;
    Cog tbl[int];
    extern task ip2(int k);
  endclass
  task IP2::ip2(int k);
    if (tbl[k].tally == 0) $display("ip2");
  endtask

  class IMisc #(int IW = 2);
    Cog tbl[int];
    int arr[8];
    rand int rv;
    int ini = tbl[IP_SLOT].tally;             // PROPERTY INITIALISER index
    constraint cc { rv < tbl[IP_SLOT].gauge; } // CONSTRAINT index
    static Cog sTbl[int];

    static task istatic(int k = 0);            // STATIC in-body method
      if (sTbl[k].tally == 0) $display("istatic");
    endtask
    task ipar();                               // CLASS PARAMETER as the index
      if (tbl[IW].tally == 0) $display("ipar");
    endtask
    task idpi(int k = 0);                      // a DPI call as the index
      if (tbl[dpiPick(k)].tally == 0) $display("idpi");
    endtask
    task ifork(int k = 0);                     // inside a FORK block
      fork
        begin
          if (tbl[k].tally == 0) $display("ifork");
        end
      join_none
    endtask
    task iforeach();                           // FOREACH: the ref_var cell
      foreach (arr[j])
        if (tbl[j].tally == 0) $display("iforeach");
    endtask
    task iforeach2();                          // foreach over the assoc array
      foreach (tbl[j])
        if (tbl[j].gauge == 0) $display("iforeach2");
    endtask
    task iwhile(int k = 0);                    // inside a while / begin block
      int n = 0;
      while (n < 2) begin
        int b;
        b = k;
        if (tbl[b].tally == 0) $display("iwhile");
        n++;
      end
    endtask
  endclass
endpackage

module topI143v;
  import pkI143v::*;
  IMisc #(3) m3; IMisc #(4) m4; IP1 p1; IP2 p2; ISuper su;
  initial begin
    m3 = new(); m4 = new(); p1 = new(); p2 = new(); su = new();
    m3.ipar(); m4.ipar(); p1.ip1(); p2.ip2(1); su.isup_tk();
  end
endmodule
