% minizinc tomato_cooker/models/tomatic/phone_grill.mzn data-example.dzn


days = [ dl, dm, dx, dj, dv ];
nHours = 4;
nLines = 8;
names = [
        alice, barb, carol, diane, emily, fanny,
        gloria, hellen, imma, joly, liza, mary,
        malice, mbarb, mcarol, mdiane, memily, mfanny,
        mgloria, mhellen, mimma, mjoly, mliza, mmary,
        xalice, xbarb, xcarol, xdiane, xemily, xfanny,
        xgloria, xhellen, ximma, xjoly, xliza, xmary,
        nobody
];
Nobodies = { nobody };
/*
names = [
        A, B, C, D, E, F,
        G, H, I, J, L, M,
        O % nobody
];
nobodies = [O];
*/
maxLoad = [
        6,2,6,5,2,3,
        6,3,5,6,4,3,
        6,2,6,5,2,3,
        6,3,5,6,4,3,
        6,2,6,5,2,3,
        6,3,5,6,4,3,
        7
];
maxPersonLoadPerDay = 2;

forced = array2d(Days, Hours, [
        {alice}, {}, {}, {barb}, % dl
        {alice}, {}, {}, {}, % dm
        {}, {}, {}, {}, % dx
        {}, {}, {}, {}, % dj
        {}, {}, {}, {}  % dv
]);

busy = array2d(Days, Hours, [
        {alice, barb, carol, diane, fanny}, {}, {barb}, {}, % dl
        {}, {}, {}, {}, % dm
        {}, {}, {}, {}, % dx
        {}, {}, {}, {}, % dj
        {}, {}, {}, {}  % dv
]);

inconvenient = array2d(Days, Hours, [
        {alice}, {alice}, {alice}, {alice}, % dl
        {barb}, {barb}, {alice, barb, carol}, {barb}, % dm
        {}, {}, {}, {}, % dx
        {}, {}, {}, {}, % dj
        {barb}, {barb}, {barb}, {barb}  % dv
]);

