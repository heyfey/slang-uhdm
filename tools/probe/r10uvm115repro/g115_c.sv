// r10uvm115 / g115_c.sv — THE SPELLING + POSITION ARM.  Every spelling of a
// builtin-class-typed declaration the law could reach, and every position the
// corpus actually uses, so a fence is written from measurement and not from
// taste.  Purpose-built golden (Surelog is the reference).
package s115;

  // (A) the SCOPED spelling `std::process`
  function void spelling();
    std::process sp;
    process bp;
    sp = std::process::self();
    bp = process::self();
  endfunction

  // (B) a local WITH AN INITIALISER (the uvm_component:3612 shape) and a
  //     nested begin/else block around it (the corpus writes it inside one)
  function void initform(int i);
    if (i == 0) begin
      process ip;
      ip = process::self();
    end
    else begin
      process jp = process::self();
      string  jr = jp.get_randstate();
    end
  endfunction

  // (C) a FORK body local
  task forkform();
    fork
      begin
        process fp;
        fp = process::self();
      end
    join_none
  endtask

  // (D) an ARRAY of the builtin type, fixed / queue / dynamic
  function void arrform();
    process afix[2];
    process aq[$];
    process adyn[];
    afix[0] = process::self();
  endfunction

  // (E) the declaration in a class that is declared INSIDE the package, with
  //     the method written IN BODY (golden RESOLVES this one) and OUT OF BODY
  class k115;
    function void inbody();
      process kp;
      kp = process::self();
    endfunction
    extern function void outbody();
  endclass
  function void k115::outbody();
    process kq;
    kq = process::self();
  endfunction

  // (F) two declarators on ONE data declaration
  function void twoform();
    process t1, t2;
    t1 = process::self();
    t2 = t1;
  endfunction

  // (G) a FORMAL typed by the builtin class, and a RETURN type
  function process retform(process arg);
    return arg;
  endfunction

endpackage

module m115;
  // (H) a module-scope initial block local and a module task
  initial begin
    process mp;
    mp = process::self();
  end
  task mtask();
    process mt;
    mt = process::self();
  endtask
endmodule
