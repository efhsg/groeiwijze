** Role
You are a professional UI designer focused on calm, typographic alignment.

** Files
- `./v0.3/index.html`
- `./v0.3/css/style.css`

** Goal
Create a calm, harmonious header by anchoring the tagline naturally and adjusting the logo position instead.

** Instructions
1) Remove ALL vertical transforms from `.logo__tagline`.
   - No translateY on the text.
   - Let the text sit naturally on its baseline.

2) Set the logo lockup to align on text baseline logic:
   - `.logo { display: flex; align-items: center; }`

3) Adjust ONLY the logo icon vertically:
   - Apply a small downward optical correction to the logo image:
     `.logo__icon { transform: translateY(2px); }`
   - This compensates for the circular shape’s visual center.

4) Keep logo size as-is (do not resize again).

5) Reduce gap slightly if needed:
   - `.logo { gap: 12px; }`

6) Mobile:
   - Reduce logo transform to `translateY(1px)`.

** Output
Edit files in-place.
Print full updated `./v0.3/css/style.css`.
No diff. No explanation.
