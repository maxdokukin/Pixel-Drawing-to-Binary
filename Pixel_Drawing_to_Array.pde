final int SCALE = 20;
boolean [][] array;
PImage img;

int pixelW, pixelH;
float gridScale = SCALE;

PVector gridBias;
PVector imageBias;

final float IMAGE_SCALAR = 0.97;

void setup() {

  long n = 2147483649L;

  println((n >> 0) & 1);
  println((n >> 31) & 1);

  gridBias = new PVector(0, 0);
  imageBias = new PVector(0, 0);

  img = loadImage("partiallyCloudy.png");

  size(32 * 20 + 1, 32 * 20 + 1);

  pixelW = int(width / SCALE);
  pixelH = int(height / SCALE);


  array = new boolean[pixelW][pixelH];
}


void draw() {

  background(100);
  image(img, imageBias.x, imageBias.y);

  for (int i = 0; i < pixelW; i++)
    for (int j = 0; j < pixelH; j++) {

      if (array[i][j])
        fill(0, 255, 255);
      else
        noFill();

      rect(gridBias.x + i * gridScale, gridBias.y + j * gridScale, gridScale, gridScale);
    }
}


void mousePressed() {

  int arrX = int((mouseX - gridBias.x)/ gridScale);
  int arrY = int((mouseY - gridBias.y)/ gridScale);

  array[arrX][arrY] = !array[arrX][arrY];
}

void mouseDragged() {

  int arrX = int((mouseX - gridBias.x)/ gridScale);
  int arrY = int((mouseY - gridBias.y)/ gridScale);

  array[arrX][arrY] = true;
}


void keyPressed() {

  if (key == '-')
    gridScale -= 0.5;
  else if (key == '+')
    gridScale += 0.5;
  else if (key == '[')
    img.resize(int(img.width * IMAGE_SCALAR), int(img.height * IMAGE_SCALAR));
  else if (key == ']')
    img.resize(int(img.width / IMAGE_SCALAR), int(img.height / IMAGE_SCALAR));

  else if (key == 's')
    gridBias.add(new PVector(0, 1));
  else if (key == 'w')
    gridBias.add(new PVector(0, -1));
  else if (key == 'a')
    gridBias.add(new PVector(-1, 0));
  else if (key == 'd')
    gridBias.add(new PVector(1, 0));

  else if (keyCode == 40)
    imageBias.add(new PVector(0, 5));
  else if (keyCode == 28)
    imageBias.add(new PVector(0, -5));
  else if (keyCode == 37)
    imageBias.add(new PVector(-5, 0));
  else if (keyCode == 39)
    imageBias.add(new PVector(5, 0));

  else if (key == 'y')
    generateStrings();


  //println(imageBias);
  //println(keyCode);
}


void generateStrings() {

  println("NEW GENERATION");

  String [] rawStrings = new String[pixelH];

  for (int i = 0; i < pixelH; i++)
    rawStrings[i] = "";

  for (int i = 0; i < pixelH; i++) {

    for (int j = 0; j < pixelW; j++)
      if (array[j][i])
        rawStrings[i] += "1";
      else
        rawStrings[i] += "0";
  }

  //println("Raw image");
  //for(String s: rawStrings)
  //  println(s);


  //allign rows
  String [] stringOutputAdjusted = centerRows(centerColumns(rawStrings));
  println("Alligned output");
  for (String s : stringOutputAdjusted)
    println(s);


  println(generateArduinoOutput(stringOutputAdjusted));
}


String generateArduinoOutput(String []a) {

  String output = "long numbers[] = {";

  for (int i = 0; i < 32; i++)
    output += Long.parseLong(a[i], 2) + ", ";


  output = output.substring(0, output.length() - 2);

  output += "};";

  return output;
}




//ROWS

String [] centerRows(String []a) {

  int rowCount = a.length;
  String [] stringOutputAdjusted = new String[rowCount];

  //initialize strings
  for (int i = 0; i < rowCount; i++)
    stringOutputAdjusted[i] = "";

  //fill with zeros
  for (int i = 0; i < rowCount; i++)
    for (int j = 0; j < a[0].length(); j++)
      stringOutputAdjusted[i] += "0";

  int firstNonZeroString = firstNonZeroRow(a);
  int nonZeroRowsCount = nonZeroRowsCount(a);
  int startingRowAdjusted = ((rowCount - nonZeroRowsCount) / 2);

  //replace rows
  for (int i = 0; i < nonZeroRowsCount; i++)
    stringOutputAdjusted[startingRowAdjusted + i] = a[firstNonZeroString + i];

  return stringOutputAdjusted;
}


int nonZeroRowsCount(String []a) {

  return lastNonZeroRow(a) - firstNonZeroRow(a) + 1;
}

int firstNonZeroRow(String []a) {

  for (int i = 0; i < a.length; i++)
    if (a[i].contains("1"))
      return i;

  return -1;
}

int lastNonZeroRow(String []a) {

  for (int i = a.length - 1; i >= 0; i--)
    if (a[i].contains("1"))
      return i;

  return -1;
}

//COLUMNS
String [] centerColumns(String []a) {

  int rowCount = a.length;

  String [] stringOutputAdjusted = new String[rowCount];

  //initialize strings
  for (int i = 0; i < rowCount; i++)
    stringOutputAdjusted[i] = "";

  int firstNonZeroCol = firstNonZeroCol(a);
  int nonZeroColsCount = nonZeroColsCount(a);
  int startingColAdjusted = (rowCount - nonZeroColsCount) / 2;

  //add leading zeros
  for (int i = 0; i < rowCount; i++)
    for (int j = 0; j < startingColAdjusted; j++)
      stringOutputAdjusted[i] += "0";

  //add non-zero columns
  for (int i = 0; i < nonZeroColsCount; i++)
    for (int j = 0; j < rowCount; j++)
      stringOutputAdjusted[j] += a[j].charAt(firstNonZeroCol + i);

  //add last zeros
  while (stringOutputAdjusted[0].length() < rowCount)
    for (int j = 0; j < rowCount; j++)
      stringOutputAdjusted[j] += "0";

  return stringOutputAdjusted;
}


int nonZeroColsCount(String []a) {

  return lastNonZeroCol(a) - firstNonZeroCol(a) + 1;
}



int lastNonZeroCol(String []a) {

  for (int i = a[0].length() - 1; i >= 0; i--)
    for (int j = 0; j < a.length; j++)
      if (a[j].charAt(i) == '1')
        return i;

  return -1;
}

int firstNonZeroCol(String []a) {

  for (int i = 0; i < a[0].length(); i++)
    for (int j = 0; j < a.length; j++)
      if (a[j].charAt(i) == '1')
        return i;

  return -1;
}

boolean columnIsEmpty(String [] strs, int col) {

  for (String s : strs)
    if (s.charAt(col) == '1')
      return false;

  return true;
}
