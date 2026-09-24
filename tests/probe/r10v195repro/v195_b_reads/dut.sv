// r10v195 arm B — ORDINARY locals MUST STAY LISTED AND BOUND, an INITIALIZED
// process local, and process locals READ IN THE BODY (so their references'
// bindings are visible after the omission).  MEASUREMENT ONLY.
package hollow195v;
  class Badger195v;
    extern task sett195v(string s195v = "");
  endclass
  task Badger195v::sett195v(string s195v = "");
    int      or_i195v = 7;        // ORDINARY local, initialized
    string   or_s195v;            // ORDINARY local
    process  pr_p195v;            // the head shape
    process  pr_q195v = null;     // INITIALIZED process local
    semaphore pr_m195v;
    or_s195v = "k";
    pr_p195v = null;              // WRITTEN in the body
    if (pr_q195v == null)         // READ in the body
      or_i195v = 1;
    if (pr_p195v == null)         // READ in the body
      or_s195v = "m";
    pr_m195v = null;
  endtask
  function int fetch195v(int a195v);
    process fe_p195v;
    int     fe_i195v;
    fe_p195v = null;
    fe_i195v = a195v;
    if (fe_p195v == null)
      fe_i195v = fe_i195v + 1;
    return fe_i195v;
  endfunction
endpackage
package warren195v;
  import hollow195v::*;
  class Stoat195v;
    function void dig195v();
      Badger195v st_h195v;
      st_h195v = null;
    endfunction
  endclass
endpackage
