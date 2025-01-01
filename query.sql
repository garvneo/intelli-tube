CREATE TABLE public.user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(150) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(150) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE
);

select * from public.user
select * from quiz
select * from questions

CREATE TABLE public.quiz (
    id SERIAL PRIMARY KEY, -- Automatically increments and acts as the primary key
    title VARCHAR(150) NOT NULL, -- Quiz title with a max length of 150 characters
    category VARCHAR(100) NOT NULL -- Quiz category with a max length of 100 characters
);

CREATE TABLE public.questions (
    id SERIAL PRIMARY KEY, -- Automatically increments and acts as the primary key
    question VARCHAR(500) NOT NULL, -- Question text with a max length of 500 characters
    question_options TEXT NOT NULL, -- Options for the question stored as TEXT
    correct_option VARCHAR(500) NOT NULL, -- Correct option with a max length of 500 characters
    explanation TEXT NOT NULL, -- Explanation of the answer
    quiz_id INTEGER NOT NULL, -- Foreign key linking to the quiz table
    CONSTRAINT fk_quiz FOREIGN KEY (quiz_id) REFERENCES public.quiz (id) ON DELETE CASCADE
);



CREATE TABLE public.quiz (
    id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    questions TEXT NOT NULL,
);

-- Step 1: Add the new column
ALTER TABLE public.quiz
ADD COLUMN question_id INT;

ALTER TABLE public.quiz
DROP COLUMN questions;
select * from questions

-- Step 2: Add the foreign key constraint
ALTER TABLE public.quiz
ADD CONSTRAINT fk_question_id
FOREIGN KEY (question_id)
REFERENCES public.questions(id);

select * from user_quiz

CREATE TABLE public.questions (
	id SERIAL PRIMARY KEY,
	question VARCHAR(500) NOT NULL,
	question_options TEXT NOT NULL,
	correct_option VARCHAR(500) NOT NULL,
	explanation TEXT NOT NULL
);

DROP TABLE IF EXISTS public.user_quiz CASCADE;

select * from user_quiz

CREATE TABLE public.user_quiz (
    id SERIAL PRIMARY KEY,
	quiz_set_id INT NOT NULL,
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    score INT NOT NULL,
    date_attempted TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES public.user(id),
    FOREIGN KEY (question_id) REFERENCES public.questions(id)
);

select * from public.user

INSERT INTO public.user (username, email, password, is_admin)
VALUES ('john_doe', 'john.doe@example.com', 'pbkdf2:sha256:600000$QjJ6zTz9vtRZEyke$fe758ea29d5b0e8f32985dd794e8aee13e1946abb9664cb62b91d74c91a2aefa
', true),
       ('jane_smith', 'jane.smith@example.com', 'pbkdf2:sha256:600000$QjJ6zTz9vtRZEyke$fe758ea29d5b0e8f32985dd794e8aee13e1946abb9664cb62b91d74c91a2aefa
', false);
INSERT INTO public.quiz (title, category, questions) VALUES
('HTML Basics', 'Web Development', '[
    {"numb": 1, "question": "What does HTML stand for?", "options": ["Hyper Type Multi Language", "Hyper Text Multiple Language", "Hyper Text Markup Language", "Home Text Multi Language"], "answer": "Hyper Text Markup Language"},
    {"numb": 2, "question": "Which HTML tag is used to define a paragraph?", "options": ["<p>", "<para>", "<text>", "<par>"], "answer": "<p>"},
    {"numb": 3, "question": "What is the correct HTML tag for inserting a line break?", "options": ["<break>", "<lb>", "<br>", "<line>"], "answer": "<br>"}
]'),
('CSS Basics', 'Web Development', '[
    {"numb": 1, "question": "What does CSS stand for?", "options": ["Cascading Style System", "Creative Style Sheets", "Computer Style Syntax", "Cascading Style Sheets"], "answer": "Cascading Style Sheets"},
    {"numb": 2, "question": "Which property is used to change the background color?", "options": ["color", "bgcolor", "background-color", "background"], "answer": "background-color"},
    {"numb": 3, "question": "Which property is used to change the font size?", "options": ["text-size", "font-style", "font-size", "text-font"], "answer": "font-size"}
]'),
('JavaScript Basics', 'Programming', '[
    {"numb": 1, "question": "What is the correct way to write an array in JavaScript?", "options": ["var colors = (1:red, 2:green, 3:blue)", "var colors = [red, green, blue]", "var colors = 1 = (red), 2 = (green), 3 = (blue)", "var colors = {red, green, blue}"], "answer": "var colors = [red, green, blue]"},
    {"numb": 2, "question": "How do you write ''Hello World'' in an alert box?", "options": ["msg(''Hello World'');", "alert(''Hello World'');", "prompt(''Hello World'');", "alertBox(''Hello World'');"], "answer": "alert(''Hello World'');"},
    {"numb": 3, "question": "Which event occurs when the user clicks on an HTML element?", "options": ["onmouseclick", "onchange", "onclick", "onmouseover"], "answer": "onclick"}
]');


INSERT INTO public.user_quiz (user_id, quiz_id, score) VALUES
(1, 1, 3), -- User 1 scored 3/3 in Quiz 1
(2, 1, 2), -- User 2 scored 2/3 in Quiz 1
(3, 2, 1), -- User 3 scored 1/3 in Quiz 2
(1, 2, 2), -- User 1 scored 2/3 in Quiz 2
(2, 3, 3), -- User 2 scored 3/3 in Quiz 3
(3, 3, 1); -- User 3 scored 1/3 in Quiz 3


INSERT INTO quiz (title, category) VALUES
('HTML Basics Quiz', 'HTML'),
('Python Fundamentals Quiz', 'Python'),
('Java Programming Quiz', 'Java'),
('C Language Quiz', 'C'),
('DSA (Data Structures & Algorithms) Quiz', 'DSA');



INSERT INTO questions (question, question_options, correct_option, explanation, quiz_id) VALUES
('What does HTML stand for?', 'Hyper Text Markup Language, Hyper Tool Markup Language, High Text Markup Language', 'Hyper Text Markup Language', 'HTML stands for Hyper Text Markup Language, the standard language for creating web pages.', 1),
('Which of the following is a Python data type?', 'int, float, bool, all of the above', 'all of the above', 'Python supports multiple data types, including int, float, and bool.', 2),
('Which is a valid Java variable declaration?', 'int x = 5;, float x = 5.5;, String x = "hello";', 'All of the above', 'Java allows multiple variable types, including int, float, and String.', 3),
('Which of the following is used for comments in C?', '/* comment */, // comment, -- comment', '/* comment */, // comment', 'In C, comments can be written using // for single-line comments and /* */ for multi-line comments.', 4),
('What is the main purpose of Data Structures?', 'To store and organize data efficiently', 'To store and organize data efficiently', 'Data structures help store and organize data efficiently for processing and retrieval.', 5),

-- Add more questions for each category (you need to insert one for each category)
('Which tag is used to create a hyperlink in HTML?', '<a>, <link>, <button>', '<a>', 'The <a> tag is used in HTML to define hyperlinks.', 1),
('What is a tuple in Python?', 'A type of list, A type of string, An immutable data structure', 'An immutable data structure', 'In Python, a tuple is an immutable sequence type.', 2),
('Which method is used to start a thread in Java?', 'start(), run(), init()', 'start()', 'The start() method is used to begin the execution of a thread in Java.', 3),
('What is the output of printf("%d", 5/2) in C?', '2, 2.5, Compilation error', '2', 'In C, integer division truncates the result to an integer.', 4),
('Which of these is not a linear data structure?', 'Array, Queue, Tree', 'Tree', 'A tree is a non-linear data structure, while array and queue are linear data structures.', 5),

('What does the <div> tag do in HTML?', 'Defines a division or section in an HTML document', 'Defines a division or section in an HTML document', '<div> is used to define sections in an HTML document.', 1),
('What is the output of 2 ** 3 in Python?', '6, 8, 4', '8', 'In Python, the operator ** is used to raise a number to the power of another.', 2),
('Which keyword is used to define a class in Java?', 'class, def, object', 'class', 'In Java, the keyword class is used to define a new class.', 3),
('Which of the following is a valid declaration in C?', 'int x = 5;, float x = 5.5;, string x = "hello";', 'int x = 5;', 'In C, int is used to declare an integer variable.', 4),
('Which algorithm is used for sorting in Data Structures?', 'QuickSort, MergeSort, Both', 'Both', 'Both QuickSort and MergeSort are used for sorting in data structures.', 5),

('How can you link an external CSS file in HTML?', '<link href="style.css" rel="stylesheet">', '<link href="style.css" rel="stylesheet">', 'The <link> tag is used to link external CSS stylesheets to an HTML document.', 1),
('What does the range function do in Python?', 'Creates a list, Generates a sequence of numbers, Both', 'Generates a sequence of numbers', 'The range function in Python generates a sequence of numbers.', 2),
('How do you declare an array in Java?', 'int[] arr = new int[10];', 'int[] arr = new int[10];', 'Arrays in Java are declared with the type followed by square brackets.', 3),
('Which of these is used for defining functions in C?', 'function, def, void', 'void', 'In C, the keyword void is used for functions that do not return any value.', 4),
('Which type of data structure is a stack?', 'LIFO, FIFO, Both', 'LIFO', 'A stack follows Last-In-First-Out (LIFO) order for element processing.', 5),

-- Add remaining questions for each category (up to 25)
('What does the <p> tag do in HTML?', 'Defines a paragraph, Defines a link', 'Defines a paragraph', 'The <p> tag is used to define paragraphs in HTML.', 1),
('What is a dictionary in Python?', 'An unordered collection of items, A list of values, An array', 'An unordered collection of items', 'Dictionaries in Python store key-value pairs and are unordered.', 2),
('Which of the following is a correct syntax for creating an object in Java?', 'MyClass obj = new MyClass();', 'MyClass obj = new MyClass();', 'In Java, objects are created using the new keyword and the class constructor.', 3),
('What is the size of an int in C?', '2 bytes, 4 bytes, 8 bytes', '4 bytes', 'On most systems, an int in C is 4 bytes in size.', 4),
('What is the space complexity of MergeSort?', 'O(n), O(nlogn), O(logn)', 'O(nlogn)', 'MergeSort has a space complexity of O(nlogn).', 5);


INSERT INTO questions (question, question_options, correct_option, explanation, quiz_id) VALUES
('What is the purpose of the <head> tag in HTML?', 'Contains metadata, Defines the main content, For styling', 'Contains metadata', 'The <head> tag contains metadata and links to stylesheets or scripts.', 1),

('What attribute is used to specify the URL in an <a> tag?', 'href, src, link', 'href', 'The href attribute specifies the URL of the link.', 1),

('Which element is used for creating a table in HTML?', '<table>, <div>, <span>', '<table>', 'The <table> element defines a table structure.', 1),

('What is the correct way to include an image in HTML?', '<img src="image.jpg">, <image src="image.jpg">, <img url="image.jpg">', '<img src="image.jpg">', 'The <img> tag requires the src attribute to link an image.', 1),

('What does the <meta> tag do?', 'Adds metadata, Creates styles, Displays content', 'Adds metadata', '<meta> provides metadata like descriptions, keywords, and author.', 1),

('What does the alt attribute in the <img> tag specify?', 'Alternate text, Alignment, Image size', 'Alternate text', 'The alt attribute provides text if the image fails to load.', 1),

('Which tag is used for creating dropdown menus in HTML?', '<select>, <input>, <dropdown>', '<select>', '<select> is used to create dropdown menus.', 1),

('How do you create an ordered list in HTML?', '<ol>, <ul>, <list>', '<ol>', '<ol> creates ordered (numbered) lists.', 1),

('What does the <title> tag do?', 'Sets the page title, Adds a tooltip, Displays a heading', 'Sets the page title', 'The <title> tag sets the title displayed on the browser tab.', 1),

('What tag is used to define a table row?', '<tr>, <td>, <row>', '<tr>', 'The <tr> tag defines a table row.', 1),

('How can you make text bold in HTML?', '<b>, <strong>, Both', 'Both', '<b> and <strong> are used to make text bold, with <strong> conveying importance.', 1),

('Which tag creates an inline frame?', '<iframe>, <frame>, <embed>', '<iframe>', '<iframe> is used for embedding another HTML document.', 1),

('What is the purpose of the <nav> tag?', 'Navigation links, Adds buttons, Styles a section', 'Navigation links', '<nav> groups navigation links.', 1),

('What does the <br> tag do in HTML?', 'Adds a line break, Creates a bold line, Makes text readable', 'Adds a line break', '<br> inserts a single line break.', 1),

('Which tag is used for creating a horizontal line?', '<hr>, <line>, <divider>', '<hr>', '<hr> adds a horizontal line as a thematic break.', 1),

('What attribute is used to define inline styles in HTML?', 'style, css, link', 'style', 'Inline styles are defined using the style attribute.', 1),

('Which element is used for adding captions to tables?', '<caption>, <title>, <footer>', '<caption>', '<caption> adds a descriptive title for a table.', 1),

('What does the target="_blank" attribute do in an <a> tag?', 'Opens a link in a new tab, Opens a link in the same tab, Adds a tooltip', 'Opens a link in a new tab', 'target="_blank" opens links in a new browser tab.', 1),

('What is the correct way to comment in HTML?', '<!-- Comment -->, // Comment, /* Comment */', '<!-- Comment -->', 'HTML comments are wrapped in <!-- -->.', 1),

('Which tag defines a multiline text input field?', '<textarea>, <input type="text">, <textbox>', '<textarea>', '<textarea> defines a multiline text input.', 1),

('What does the colspan attribute do in HTML tables?', 'Merges columns, Merges rows, Adds spacing', 'Merges columns', 'colspan specifies the number of columns a cell spans.', 1),

('What does the <link> tag do?', 'Links external stylesheets, Adds inline CSS, Creates hyperlinks', 'Links external stylesheets', '<link> is used to include external resources like CSS files.', 1),

('What does the <body> tag define?', 'Page content, Metadata, Styles', 'Page content', '<body> contains the visible page content.', 1),

('What is the purpose of the <form> tag?', 'Collects user input, Adds styles, Links pages', 'Collects user input', '<form> is used for creating input fields to collect user data.', 1),

('How can you specify the language of an HTML document?', '<html lang="en">, <meta lang="en">, <body lang="en">', '<html lang="en">', 'The lang attribute in <html> specifies the document language.', 1);


INSERT INTO questions (question, question_options, correct_option, explanation, quiz_id) VALUES
('What is the output of print(3 * "hi")?', 'hi, hihi, hihihi', 'hihihi', 'In Python, multiplying a string by an integer repeats the string.', 2),
('What is a lambda function in Python?', 'A named function, An anonymous function, A class method', 'An anonymous function', 'Lambda functions are single-expression anonymous functions in Python.', 2),
('How can you convert a list into a set in Python?', 'Using list(), Using set(), Using dict()', 'Using set()', 'The set() function converts a list into a set, removing duplicates.', 2),
('Which module is used to generate random numbers?', 'random, math, os', 'random', 'The random module provides functions to generate random numbers.', 2),
('What is the use of the pass statement in Python?', 'To end a loop, To create a placeholder, To break a loop', 'To create a placeholder', 'The pass statement acts as a placeholder in loops, functions, or classes.', 2),
('Which Python function is used to get the length of a string?', 'strlen(), len(), size()', 'len()', 'len() returns the length of an object like a string, list, or tuple.', 2),
('What is the difference between is and == in Python?', 'No difference, is checks identity, == checks equality, is checks equality, == checks identity', 'is checks identity, == checks equality', 'The is operator checks if two variables reference the same object, while == compares values.', 2),
('Which keyword is used to handle exceptions in Python?', 'try, except, raise', 'except', 'The except block handles exceptions in Python.', 2),
('What is a Python list?', 'A mutable sequence, An immutable sequence, A dictionary', 'A mutable sequence', 'Lists are ordered, mutable collections of items in Python.', 2),
('What does the zip() function do?', 'Combines iterables, Slices a list, Splits a string', 'Combines iterables', 'zip() combines multiple iterables into tuples.', 2),
('What is the correct syntax to create a dictionary in Python?', '{key: value}, [key: value], (key, value)', '{key: value}', 'Dictionaries in Python are created using curly braces with key-value pairs.', 2),
('What does the eval() function do?', 'Evaluates strings as code, Prints strings, Executes a loop', 'Evaluates strings as code', 'eval() evaluates a string as Python code.', 2),
('Which keyword is used to define a generator function?', 'def, yield, gen', 'yield', 'The yield keyword is used to create generator functions in Python.', 2),
('What is the default return value of a function without a return statement?', 'None, 0, Undefined', 'None', 'In Python, functions return None by default.', 2),
('What does the open() function do?', 'Reads files, Opens files, Writes files', 'Opens files', 'open() is used to open a file for reading, writing, or appending.', 2),
('Which operator is used for floor division in Python?', '/, //, %', '//', '// performs floor division, returning the integer quotient.', 2),
('What does the with statement do in Python?', 'Handles files, Automatically closes resources, Both', 'Both', 'with handles file context and ensures resources are automatically closed.', 2),
('How can you create a virtual environment in Python?', 'Using venv module, Using pip, Using setup.py', 'Using venv module', 'The venv module is used to create isolated Python environments.', 2),
('What does the super() function do in Python?', 'Calls parent class methods, Returns a list, Returns None', 'Calls parent class methods', 'super() calls methods from the parent class in inheritance.', 2),
('How do you reverse a list in Python?', 'Using reverse(), Using reversed(), Both', 'Both', 'reverse() modifies the list in place, while reversed() creates an iterator.', 2),
('What is the output of print(type([]))?', '<class list>, <type list>, <list>', '<class list>', 'In Python, [] creates a list, and its type is <class list>.', 2),
('What does PEP stand for?', 'Python Enhancement Proposal, Python Evaluation Protocol, Python Environment Proposal', 'Python Enhancement Proposal', 'PEP documents describe new features or guidelines in Python.', 2),
('Which Python keyword is used to define an abstract base class?', 'ABC, abstract, @abstractmethod', '@abstractmethod', '@abstractmethod is used to define abstract methods in a class.', 2),
('What does the term GIL stand for in Python?', 'Global Interpreter Lock, Global Integer Limit, General Input Loop', 'Global Interpreter Lock', 'The GIL in Python prevents multiple threads from executing simultaneously.', 2),
('Which library is used for data manipulation in Python?', 'NumPy, pandas, matplotlib', 'pandas', 'pandas is a powerful library for data manipulation and analysis in Python.', 2);


INSERT INTO questions (question, question_options, correct_option, explanation, quiz_id) VALUES
('What is the default value of an int variable in Java?', '0, null, undefined', '0', 'In Java, the default value of an int is 0.', 3),
('What does the keyword static mean in Java?', 'A shared class-level variable, A private variable, A final variable', 'A shared class-level variable', 'Static variables and methods belong to the class rather than instances.', 3),
('Which method is called to explicitly release resources in Java?', 'dispose(), finalize(), close()', 'close()', 'The close() method is commonly used to release resources like files.', 3),
('Which of these is not a Java primitive type?', 'String, int, char', 'String', 'String is not a primitive type; it is a class.', 3),
('What is the purpose of the final keyword in Java?', 'To create constants, To prevent inheritance, Both', 'Both', 'The final keyword is used to create constants and prevent overriding or inheritance.', 3),
('Which exception is thrown when an array is accessed with an invalid index?', 'IndexOutOfBoundsException, NullPointerException, ArrayStoreException', 'IndexOutOfBoundsException', 'This exception occurs when attempting to access an index outside an arrays bounds.', 3),
('Which method is used to start an application thread in Java?', 'run(), start(), execute()', 'start()', 'The start() method begins a threads execution.', 3),
('What is the size of a boolean in Java?', '1 bit, 1 byte, JVM dependent', 'JVM dependent', 'The size of a boolean is not precisely defined in Java.', 3),
('What is the correct way to declare an array in Java?', 'int[] arr;, int arr[], both are valid', 'both are valid', 'Both int[] arr; and int arr[]; are valid array declarations in Java.', 3),
('Which package is imported by default in every Java program?', 'java.lang, java.util, java.io', 'java.lang', 'The java.lang package is automatically imported.', 3),
('What is the purpose of the break statement in Java?', 'To exit a loop, To continue a loop, To skip an iteration', 'To exit a loop', 'The break statement terminates a loop or switch case.', 3),
('What is the superclass of all classes in Java?', 'Object, Class, System', 'Object', 'All Java classes implicitly inherit from the Object class.', 3),
('What is the maximum size of a byte in Java?', '127, 255, 32,767', '127', 'A byte in Java has a range of -128 to 127.', 3),
('Which of the following is a valid constructor in Java?', 'MyClass(), void MyClass(), static MyClass()', 'MyClass()', 'Constructors in Java cannot have a return type.', 3),
('What is the output of 10 >> 2 in Java?', '2, 3, 2.5', '2', 'The >> operator performs a signed right shift, dividing by 2 power of 2.', 3),
('Which interface is used to handle collections in Java?', 'Collection, Iterable, Set', 'Collection', 'The Collection interface is the root of the collection hierarchy.', 3),
('What is the purpose of the instanceof keyword?', 'To check inheritance, To cast objects, Both', 'To check inheritance', 'instanceof checks if an object is an instance of a specific class or subclass.', 3),
('What does the continue statement do in Java?', 'Skips to the next iteration, Exits the loop, Terminates the program', 'Skips to the next iteration', 'The continue statement skips the current iteration and moves to the next.', 3),
('Which keyword is used to inherit a class in Java?', 'extends, implements, inherits', 'extends', 'The extends keyword is used to inherit a class.', 3),
('What does JVM stand for?', 'Java Virtual Machine, Java Version Manager, Java Variable Manager', 'Java Virtual Machine', 'The JVM executes Java bytecode on any platform.', 3),
('Which of these is not part of the Java Collection Framework?', 'TreeNode, HashMap, Vector', 'TreeNode', 'TreeNode is not part of the Collection Framework.', 3),
('What is the purpose of the synchronized keyword in Java?', 'To achieve thread safety, To speed up execution, To prevent compilation errors', 'To achieve thread safety', 'The synchronized keyword is used to prevent thread interference.', 3),
('What is the use of the transient keyword in Java?', 'To serialize a field, To prevent serialization, To declare constants', 'To prevent serialization', 'The transient keyword prevents a field from being serialized.', 3),
('What is the difference between == and equals() in Java?', 'No difference, == compares references, equals() compares values', '== compares references, equals() compares values', 'The == operator checks memory references, while equals() compares object values.', 3),
('Which of the following is a checked exception in Java?', 'IOException, NullPointerException, ArithmeticException', 'IOException', 'Checked exceptions like IOException must be handled at compile time.', 3);


INSERT INTO questions (question, question_options, correct_option, explanation, quiz_id) VALUES
('What is the size of a char in C?', '1 byte, 2 bytes, 4 bytes', '1 byte', 'In C, a char is 1 byte on most systems.', 4),
('Which header file is required for using printf in C?', 'stdio.h, stdlib.h, conio.h', 'stdio.h', 'The stdio.h library includes the printf function.', 4),
('What does the sizeof operator return in C?', 'Size of a variable, Address of a variable, Value of a variable', 'Size of a variable', 'sizeof returns the size (in bytes) of a variable or data type.', 4),
('What is the correct way to define a constant in C?', '#define, const, Both', 'Both', 'Constants can be defined using #define or the const keyword.', 4),
('What is the default value of a global variable in C?', '0, Garbage value, Undefined', '0', 'Global variables in C are initialized to 0 by default.', 4),
('Which keyword is used to return a value from a function in C?', 'return, void, exit', 'return', 'The return keyword is used to return values from functions.', 4),
('What is the output of printf("%d", 10/3)?', '3, 3.33, Compilation error', '3', 'In C, integer division truncates decimal values.', 4),
('Which data type is used for storing large integer values in C?', 'long, int, double', 'long', 'long is used for storing large integer values.', 4),
('Which operator is used to access the address of a variable?', '&, *, ->', '&', 'The & operator is used to get the address of a variable.', 4),
('What is the use of the break statement in C?', 'Exits a loop or switch, Skips an iteration, Repeats a loop', 'Exits a loop or switch', 'The break statement is used to exit a loop or a switch case.', 4),
('What is the output of printf("%c", 65)?', 'A, 65, Undefined', 'A', 'In C, 65 is the ASCII code for the character A.', 4),
('What is the purpose of a pointer in C?', 'Stores address of a variable, Points to memory, Both', 'Both', 'Pointers store addresses and allow direct memory access.', 4),
('Which loop is executed at least once in C?', 'for, while, do-while', 'do-while', 'In a do-while loop, the body is executed before the condition is checked.', 4),
('What does the keyword typedef do in C?', 'Defines a new type, Creates a macro, Allocates memory', 'Defines a new type', 'typedef allows the creation of new type names.', 4),
('What is the range of values for an unsigned int in C?', '0 to 4,294,967,295, -2,147,483,648 to 2,147,483,647, Undefined', '0 to 4,294,967,295', 'An unsigned int in C stores only non-negative values.', 4),
('Which function is used to allocate memory dynamically in C?', 'malloc(), calloc(), Both', 'Both', 'malloc() and calloc() are used for dynamic memory allocation.', 4),
('What is a void pointer in C?', 'A pointer that points to no specific type, A pointer to a function, A null pointer', 'A pointer that points to no specific type', 'Void pointers are generic pointers that can point to any data type.', 4),
('What does the continue statement do in C?', 'Skips an iteration, Exits the loop, Repeats the loop', 'Skips an iteration', 'The continue statement skips the current iteration and moves to the next.', 4),
('What is the output of printf("%p", &x)?', 'Address of x, Value of x, Undefined', 'Address of x', 'The %p format specifier prints the address of a variable.', 4),
('Which keyword is used to include external libraries in C?', '#include, #define, import', '#include', 'The #include directive includes external libraries in C.', 4),
('What is the purpose of the goto statement in C?', 'Transfers control to a label, Ends a program, Repeats a loop', 'Transfers control to a label', 'goto is used to transfer control to a labeled statement.', 4),
('What is the output of sizeof(int)?', '4, 2, System-dependent', 'System-dependent', 'The size of int is system-dependent, often 4 bytes on modern systems.', 4),
('What is the purpose of the fprintf function in C?', 'Writes to a file, Reads from a file, Writes to the console', 'Writes to a file', 'fprintf writes formatted output to a file.', 4),
('What does the preprocessor directive #ifdef do?', 'Checks if a macro is defined, Includes a file, Allocates memory', 'Checks if a macro is defined', '#ifdef checks if a specific macro is defined in the program.', 4),
('What is the output of printf("%f", 5/2)?', '2.000000, 2.500000, Undefined', '2.000000', 'Integer division in C truncates the result, but it is formatted as a float.', 4);


INSERT INTO questions (question, question_options, correct_option, explanation, quiz_id) VALUES
('Which data structure uses FIFO order?', 'Queue, Stack, Linked List', 'Queue', 'A Queue follows First In First Out (FIFO) order for processing elements.', 5),
('What is the time complexity of searching in a balanced binary search tree?', 'O(log n), O(n), O(1)', 'O(log n)', 'In a balanced BST, the height is logarithmic, making search O(log n).', 5),
('Which data structure is used for depth-first traversal of a graph?', 'Stack, Queue, Array', 'Stack', 'Depth-first traversal uses a stack for backtracking.', 5),
('What is a self-balancing binary search tree?', 'AVL Tree, Binary Heap, Trie', 'AVL Tree', 'An AVL tree maintains balance by ensuring the height difference is at most 1.', 5),
('What is the primary advantage of a linked list over an array?', 'Dynamic size, Faster access time, Constant space usage', 'Dynamic size', 'A linked list can grow or shrink dynamically, unlike an array.', 5),
('What is the time complexity of inserting at the end of a singly linked list?', 'O(n), O(1), O(log n)', 'O(n)', 'Traversal to the last node takes O(n) time in a singly linked list.', 5),
('Which of the following is a non-linear data structure?', 'Tree, Stack, Queue', 'Tree', 'Trees are hierarchical, making them non-linear data structures.', 5),
('What is the maximum number of children a binary tree node can have?', '2, 1, Unlimited', '2', 'Each node in a binary tree can have at most two children.', 5),
('What is the space complexity of Breadth-First Search?', 'O(V), O(E), O(V + E)', 'O(V)', 'BFS uses a queue that can grow up to the number of vertices.', 5),
('Which of the following is a balanced binary tree?', 'AVL Tree, Binary Heap, Linked List', 'AVL Tree', 'An AVL tree is balanced by ensuring height differences are minimal.', 5),
('What is a circular queue?', 'A queue where the last position is connected to the first, A priority queue, A stack', 'A queue where the last position is connected to the first', 'Circular queues connect the end to the beginning for efficient space utilization.', 5),
('What does a hash function do in a hash table?', 'Maps keys to indices, Sorts data, Compresses data', 'Maps keys to indices', 'A hash function calculates an index for storing and retrieving keys efficiently.', 5),
('What is the main advantage of a doubly linked list over a singly linked list?', 'Traversal in both directions, Constant insertion time, Lower memory usage', 'Traversal in both directions', 'A doubly linked list allows traversal forward and backward.', 5),
('Which traversal technique visits nodes level by level?', 'Breadth-First Search, Depth-First Search, Preorder Traversal', 'Breadth-First Search', 'BFS explores all nodes at a level before moving to the next.', 5),
('What is a full binary tree?', 'A tree where all nodes have 0 or 2 children, A tree where every level is full, A tree with only one child per node', 'A tree where all nodes have 0 or 2 children', 'A full binary tree has nodes with either two children or none.', 5),
('Which of these data structures is used in LRU cache implementation?', 'HashMap and Doubly Linked List, Array and Queue, Stack and Tree', 'HashMap and Doubly Linked List', 'LRU cache uses a HashMap for O(1) access and a doubly linked list for order.', 5),
('What is the time complexity of searching in a hash table?', 'O(1), O(log n), O(n)', 'O(1)', 'Hash tables offer constant-time average search complexity.', 5),
('Which sorting algorithm is based on divide and conquer?', 'Merge Sort, Bubble Sort, Insertion Sort', 'Merge Sort', 'Merge Sort divides the array, sorts, and then merges it.', 5),
('What is the purpose of a priority queue?', 'To serve elements based on priority, To maintain FIFO order, To store unique keys', 'To serve elements based on priority', 'Priority queues serve elements with higher priority first.', 5),
('Which data structure supports Last In First Out (LIFO) operations?', 'Stack, Queue, Array', 'Stack', 'A stack follows the LIFO principle for adding and removing elements.', 5),
('What is the time complexity of inserting in a max heap?', 'O(log n), O(1), O(n)', 'O(log n)', 'Inserting into a max heap requires log n comparisons to maintain heap property.', 5),
('What is the purpose of the adjacency list in graphs?', 'To represent edges, To find shortest paths, To store weights', 'To represent edges', 'Adjacency lists represent edges for each vertex efficiently.', 5),
('What is the in-order traversal of a binary search tree?', 'Left, Root, Right, Root, Left, Right, Right, Left, Root', 'Left, Root, Right', 'In in-order traversal, nodes are visited in ascending order.', 5),
('Which of these is not a characteristic of a graph?', 'Cyclic, Hierarchical, Connected', 'Hierarchical', 'Graphs can be cyclic or connected, but they are not inherently hierarchical.', 5),
('What is a spanning tree?', 'A tree that connects all vertices in a graph, A binary tree, A tree with minimum edges', 'A tree that connects all vertices in a graph', 'A spanning tree is a subgraph that connects all vertices without cycles.', 5);
