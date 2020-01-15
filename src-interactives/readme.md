Files that have been modified for the AIR app have a hyphen and a letter appended to their names, starting with "-B".

There are two common bugs in the ranking task code (usually these are found in the `include_root.txt` file, but they may located inside the FLA itself):

Problem 1: Items may be dragged beyond the drag area.
Solution:
- Find the `dragObject.startDrag` function call in the `drag_Start` function.
- Replace the fourth argument, `myRoot_width`, with `itemArea._width`.

Problem 2: Sometimes releasing an object does not work.
Solution:
- Search for all occurances of `onReleaseOutside` (there are several).
- Identify and fix apparent copy-and-paste errors like the following example:
    `equivButton.onRelease = itemObject.onReleaseOutside=function () {`
  In the example above `equivButton` is the intended object for both handlers but `itemObject` was never changed after copy-and-pasting code. Inspecting the surrounding code should make it apparent what the intended object was.


