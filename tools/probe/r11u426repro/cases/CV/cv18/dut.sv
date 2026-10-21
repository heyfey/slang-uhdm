// § namedTypeLocalTfItemOutsideClass426
class A;
  int j;
endclass
program prg;
  function integer test;
    A a1;
    a1 = new;
    test = a1.j;
  endfunction
endprogram
