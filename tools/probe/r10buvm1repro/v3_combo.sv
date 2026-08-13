// VERIFIER probe v3 — the KNOWN mover and the randomize candidate side by side
// in ONE file, so a file-level difference cannot explain a null result.
package p3v;
  int pq3[$];
  int px3;
  class c3v; static int s3; endclass
endpackage
module m3v;
  int ok, x;
  function automatic int f3v();
    int y;
    p3v::pq3.push_back(1);      // C1 known mover (built-in method, pkg recv)
    y = randomize(p3v::px3);    // C2 scope randomize, pkg-var arg0
    y += randomize(p3v::c3v::s3); // C3 scope randomize, class-static arg0
    y += p3v::pq3.size();       // C4 known mover (expression position)
    return y;
  endfunction
  initial ok = f3v();
endmodule
