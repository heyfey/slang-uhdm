// r10vbuvm21repro/v4timing.sv — the TIMING/WAIT boundary the pass's law missed:
// which procedural timing control is TRANSPARENT to Surelog's eager bind.
// Decoded: `compileEventControlStmt` (CompileStmt.cpp:1374) sets
// `event->VpiParent(pstmt)` BEFORE compiling the inner statement, so the walk
// reaches the subroutine; `compileProceduralTimingControlStmt`
// (CompileHelper.cpp:3016) never parents its `delay_control` and
// `paWait_statement` (CompileStmt.cpp:720) never parents its `wait_stmt`, so
// the walk dead-ends there.
package vp4;
  typedef enum { A4, B4 } ve4;
  class vc4;
    int aa[ve4];
    int p4;
    bit clk4;
    event ev4;
    // EVENT control — golden BINDS
    task e_plain(ve4 s);      @(ev4) aa[s]++;                 endtask
    task e_edge(ve4 s);       @(posedge clk4) aa[s]++;        endtask
    task e_beg(ve4 s);        @(ev4) begin aa[s]++; end       endtask
    task e_or(ve4 s);         @(ev4 or posedge clk4) aa[s]++; endtask
    // DELAY control — golden BARE
    task d_plain(ve4 s);      #1 aa[s]++;                     endtask
    task d_zero(ve4 s);       #0 aa[s]++;                     endtask
    task d_beg(ve4 s);        #1 begin aa[s]++; end           endtask
    task d_inbeg(ve4 s);      begin #1 aa[s]++; end           endtask
    task d_infork(ve4 s);     fork #1 aa[s]++; join           endtask
    // MIXED nesting
    task m_evdel(ve4 s);      @(ev4) #1 aa[s]++;              endtask
    task m_delev(ve4 s);      #1 @(ev4) aa[s]++;              endtask
    // WAIT — golden BARE
    task w_plain(ve4 s);      wait (p4) aa[s]++;              endtask
    task w_beg(ve4 s);        wait (p4) begin aa[s]++; end    endtask
    task w_inbeg(ve4 s);      begin wait (p4) aa[s]++; end    endtask
    task w_evwait(ve4 s);     @(ev4) wait (p4) aa[s]++;       endtask
    // LEAK tests: a statement AFTER an opaque carrier must still bind
    task l_afterdel(ve4 s);   begin #1 aa[s]++; aa[s]++; end  endtask
    task l_afterwait(ve4 s);  begin wait (p4) aa[s]++; aa[s]++; end endtask
    // controls
    task c_plain(ve4 s);      aa[s]++;                        endtask
    task c_beg(ve4 s);        begin aa[s]++; end              endtask
  endclass
  // PACKAGE free subroutines: the late-binding list rescues these in every
  // carrier, so golden binds even under a delay / wait (control that the
  // carrier exclusion must NOT reach out of the class home).
  int p4_arr[ve4];
  int p4_c;
  task pf_del(ve4 s);         #1 p4_arr[s]++;                 endtask
  task pf_wait(ve4 s);        wait (p4_c) p4_arr[s]++;        endtask
  task pf_plain(ve4 s);       p4_arr[s]++;                    endtask
endpackage
