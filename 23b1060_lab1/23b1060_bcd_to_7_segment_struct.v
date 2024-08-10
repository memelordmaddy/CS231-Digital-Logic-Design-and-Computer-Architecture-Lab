module A(input x, input y, input z, input w, output oa);
    wire p,q;
    not (nx, x);
    not (ny, y);
    not (nw, w);
    not (nz, z);
    or (p,x,ny,w);
    or (q,x,y,z,nw);
    and (oa,p,q);

endmodule

module B(input x, input y, input z, input w, output ob);
    wire nx, ny, nw, nz;
    wire p, q;
    not (nx, x);
    not (ny, y);
    not (nw, w);
    not (nz, z);
    or (p, x, ny, z, nw);
    or (q, x, ny, nz, w);
    and (ob, p, q);
endmodule

module C(input x, input y, input z, input w, output oc);
    wire nx, ny, nw, nz;
    not (nx, x);
    not (ny, y);
    not (nw, w);
    not (nz, z);
    or (oc, x, y, nz, w);
endmodule

module D(input x, input y, input z, input w, output od);
    wire nx, ny, nw, nz;
    wire l, m, n;
    not (nx, x);
    not (ny, y);
    not (nw, w);
    not (nz, z);
    or (l, x, ny, z, w);
    or (m, y, z, nw);
    or (n, x, ny, nz, nw);
    and (od, l, m, n);
endmodule

module E(input x, input y, input z, input w, output oe);
    wire nx, ny, nw, nz;
    wire m, n;
    not (nx, x);
    not (ny, y);
    not (nw, w);
    not (nz, z);
    and (m, nx, z, nw);
    and (n, ny, nz, nw);
    or (oe, m, n);
endmodule

module F(input x, input y, input z, input w, output of);
    wire nx, ny, nw, nz;
    wire p, q, r;
    not (nx, x);
    not (ny, y);
    not (nw, w);
    not (nz, z);
    or (p, x, y, nw);
    or (q, x, y, nz);
    or (r, x, nz, nw);
    and (of, p, q, r);
endmodule

module G(input x, input y, input z, input w, output og);
    wire nx, ny, nw, nz;
    wire c, d;
    not (nx, x);
    not (ny, y);
    not (nw, w);
    not (nz, z);
    or (c, x, y, z);
    or (d, x, ny, nz, nw);
    and (og, c, d);
endmodule
