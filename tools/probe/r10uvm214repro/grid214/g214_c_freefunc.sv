// r10uvm214 grid arm C — THE PACKAGE FREE-SUBROUTINE CONTROL.  A free package
// function's body is emitted in the package's OWN def pass (pkgEmitTopView
// false), so its parameter references already chain per view (§ 178 /
// § pkgOwnParamRefActualIsRhs17).  Every cell here is a MUST-STAY: the law this
// pass writes must not touch a listing that is already golden's.
package pc214p;

  parameter int ra214 = 7;
  parameter rb214 = ra214;
  parameter rc214 = ra214 + 2;
  parameter string rs214 = "rrr";

  function automatic int rsink214(int a, int b);
    return a + b;
  endfunction

  function automatic int free_arg214();
    return rsink214(ra214, rb214);
  endfunction

  function automatic int free_asgn214();
    int r;
    r = rb214;
    r = rc214;
    return r;
  endfunction

  function automatic int free_ret214();
    return rb214;
  endfunction

  function automatic string free_str214();
    return rs214;
  endfunction

  task automatic free_tk214();
    int r;
    r = rsink214(rb214, rc214);
  endtask

endpackage

module topc214;
  int x;
  initial x = pc214p::free_arg214();
endmodule
