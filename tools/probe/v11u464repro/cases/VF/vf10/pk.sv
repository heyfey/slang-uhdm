// § unitImpTfNameDedup464 (control: the two imports in two files; packages file)
package p1;
  function automatic int f(int x); return x + 1; endfunction
endpackage
package p2;
  function automatic int f(int x); return x + 2; endfunction
endpackage
