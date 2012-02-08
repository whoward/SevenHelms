# Description
This is a BASIC program written by Matt Terry and Will Howard during their early high school years while learning programming.  The source code is absolutely atrocious and the writing is terrible - nevertheless it is wonderfully nostalgic which is the only reason you're finding it here.

Most of the original source code is as is, we were actually unable to find the final build of the game but instead found this version which is very close to the last build of the program. However the game does error out in the end and you may find a few bugs elsewhere in the program since it's not "complete".

I've updated this program to compile with FreeBasic (http://www.freebasic.net/) and I've also extracted and stubbed out the API of the DS4QB2 (DirectSound for QuickBasic) library we used originally which doesn't work in modern Windows systems (not to mention never having the chance of working on Linux).  The parts we used of the DS4QB2 API have been replaced with FBSound which is cross platform.

# Installation

1. Check yourself for signs of madness, if found please consult a physician.

2. Install the FreeBasic compiler (http://www.freebasic.net/)

3. Continue with OS-specific instructions (below)

### Linux Users (Ubuntu instructions given)

1. Install required libraries for FreeBasic 

    ```apt-get install libx11-dev libxext-dev libxpm-dev libxrandr-dev libxrender-dev```

2. Install required libraries for FBSound 
    
     ```apt-get install libOGG-dev libvorbis-dev libasound2-dev```

3. Run "make" from the root directory 

    ```make```

4. enjoy the game (be gentle with criticism)

    ```./seven-helms```

### Windows Users

1. Try to be as awesome as Linux
