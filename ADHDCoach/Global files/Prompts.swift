//
//  Prompts.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/4/24.
//
import Foundation

struct Prompts {
    
    // ---------------------------------------
    // SECTION 1: Prompts for ADHD
    // ---------------------------------------
    
    // #1 Prompt used in `ImportSyllabusView.swift` and `CourseDetailView.swift for ADHD`
    static func adhdSyllabusAnalysisPrompt(syllabusText: String) -> String {
        return """
        🔵 Please summarize the following syllabus in an outline format with bullet points.
        Focus on the number of textbooks required, the number of units, assignments, and any key objectives or important information.

        Here is the syllabus: \(syllabusText)

        After summarizing, offer a motivational message to help the student with ADHD stay organized and focused. Emphasize breaking down tasks into manageable steps, avoiding distractions, and keeping track of deadlines in a clear, simple way.
        """
    }

    // #2 Crisis plan prompt for ADHD
    static func crisisPlanPrompt(userInput: String, allAssignments: [String], allSyllabuses: [String]) -> String {
        let assignmentsSummary = allAssignments.joined(separator: "\n")
        let syllabusSummary = allSyllabuses.joined(separator: "\n")
        
        return """
        🔵 I am a student with ADHD and I feel overwhelmed by my assignments and syllabus details. I am feeling anxious. Here's what's going on: "\(userInput)".
        Please analyze all of my assignments and syllabus information to propose a clear and supportive action plan.
        
        Below are the key details from my assignments and courses:
        \(assignmentsSummary)
        
        Course details:
        \(syllabusSummary)
        
        Provide a step-by-step plan to help me manage my workload effectively, breaking down larger tasks into smaller, manageable parts with clear deadlines. Use the due dates to determine what I should work on first. I'm anxious so comfort me, and motivate me to continue. Ensure the plan considers my ADHD, with strategies for staying focused, managing distractions, and maintaining motivation throughout the process. Tell me there is also help on the campus. Consider I'm a big fan of Naruto and use analogies to keep me motivated.
        """
    }

    // #3 Assignment strategy prompt for ADHD
    static func assignmentStrategy(title: String, dueDate: String, details: String) -> String {
        return """
        🔵 I have an assignment titled "\(title)" which is due on \(dueDate). The assignment details are as follows: \(details).

        You are an ADHD coach helping a student with ADHD complete a homework assignment. The student needs clear, short, and concise steps. Analyze details of the assignment and determine an objective. State the objective in a clear sentence at the top of your summary, and the total number of steps. Tell the user to stop other internet activity until at least the first step is complete. Use tough love and sarcasm. If multiple objectives, list them. Create a step-by-step plan in the tone of anime and Naruto style. Use motivational language and tips for how to approach school for help. Double spaces between steps. Remind the user that this is easy and to do 1 step at a time.
        """
    }

    // #4 Assignment strategy prompt with feedback for ADHD
    static func assignmentStrategyWithFeedback(title: String, dueDate: String, details: String, feedback: String) -> String {
        return """
        🔵 You previously provided a strategy for the following assignment:
        Title: \(title)
        Due Date: \(dueDate)
        Details: \(details)

        The user has given the following feedback:
        \(feedback)

        Please revise the strategy accordingly.
        """
    }

    // #5 Motivational message for ADHD
    static let motivationalPrompt = """
        🔵 Provide a motivational message that can help the user stay focused and remind them that they can handle the upcoming tasks. Include words of encouragement, especially in relation to the current workload and assignments. Start the message with saying you are a frog.
    """
    
    // ---------------------------------------
    // SECTION 2: Prompts for Dyslexia
    // ---------------------------------------
    
    // #6 Prompt used in `ImportSyllabusView.swift` and `CourseDetailView.swift for Dyslexia`
    static func dyslexiaSyllabusAnalysisPrompt(syllabusText: String) -> String {
        return """
        🟢 Please summarize the following syllabus in an outline format with bullet points.
        Focus on the number of textbooks required, the number of units, assignments, and any key objectives or important information.

        Here is the syllabus: \(syllabusText)

        After summarizing, provide suggestions for tools like text-to-speech software or audiobooks to assist with reading comprehension. Include a motivational message that encourages the student to use these tools and strategies to stay on top of their work, while acknowledging the challenges of Dyslexia.
        """
    }
    // #7 Crisis plan prompt for Dyslexia
    static func dyslexiaCrisisPlanPrompt(userInput: String, allAssignments: [String], allSyllabuses: [String]) -> String {
        let assignmentsSummary = allAssignments.joined(separator: "\n")
        let syllabusSummary = allSyllabuses.joined(separator: "\n")
        
        return """
        🟢 I am a student with Dyslexia, and I am having difficulty managing my assignments and syllabus. Here's what's going on: "\(userInput)".
        
        Below are the details of my assignments:
        \(assignmentsSummary)
        
        Syllabus details:
        \(syllabusSummary)
        
        Create a plan that emphasizes clear, structured steps, breaking tasks into smaller, manageable parts. Ensure that reading strategies, such as using multisensory techniques (e.g., text-to-speech, visual aids), are highlighted. Include prioritization techniques to help manage time effectively, and ensure instructions are concise and straightforward to accommodate my Dyslexia.
        """
    }

    // #8 Assignment strategy prompt for Dyslexia
    static func dyslexiaAssignmentStrategy(title: String, dueDate: String, details: String) -> String {
        return """
        🟢 I have an assignment titled "\(title)" which is due on \(dueDate). The assignment details are as follows: \(details).
        
        You are helping a student with Dyslexia complete a homework assignment. Break down the assignment into small, clear steps, using short, straightforward instructions. Highlight strategies such as the use of multisensory learning tools (e.g., reading aloud, text-to-speech software, or mind maps) to assist with comprehension. Suggest ways to organize the task visually and include checkpoints for review and feedback.
        """
    }

    // #9 Motivational message for Dyslexia
    static let dyslexiaMotivationalPrompt = """
        🟢 Provide a motivational message that reinforces the student's strengths, such as their problem-solving ability and creativity. Acknowledge the challenges they face with Dyslexia, but emphasize how using techniques like structured steps, tools like text-to-speech, and frequent breaks can help them achieve their goals. Encourage them to stay persistent and visualize the feeling of accomplishment.
    """

    // ---------------------------------------
    // SECTION 3: Prompts for Both ADHD and Dyslexia
    // ---------------------------------------
    
    // #10 Prompt used in `ImportSyllabusView.swift` and `CourseDetailView.swift for both Dyslexia and ADHD`
    static func bothSyllabusAnalysisPrompt(syllabusText: String) -> String {
        return """
        🔴 Please summarize the following syllabus in an outline format with bullet points.
        Focus on the number of textbooks required, the number of units, assignments, and any key objectives or important information.

        Here is the syllabus: \(syllabusText)

        After summarizing, offer strategies to help with both ADHD and Dyslexia, such as using visual aids, audiobooks, and working in short, timed intervals. Provide a motivational message encouraging the student to focus on one step at a time while using tools and methods that suit both conditions.
        """
    }

    // #11 Crisis plan prompt for both ADHD and Dyslexia
    static func bothCrisisPlanPrompt(userInput: String, allAssignments: [String], allSyllabuses: [String]) -> String {
        let assignmentsSummary = allAssignments.joined(separator: "\n")
        let syllabusSummary = allSyllabuses.joined(separator: "\n")
        
        return """
        🔴 I am a student with both ADHD and Dyslexia, and I am struggling with my assignments and syllabus details. Here's what's going on: "\(userInput)".
        
        Below are the key details from my assignments:
        \(assignmentsSummary)
        
        Syllabus details:
        \(syllabusSummary)
        
        Create a plan that accommodates both ADHD and Dyslexia, breaking tasks into small, manageable steps. Use multisensory tools such as text-to-speech for reading and visual aids for organizing tasks. Focus on strategies that help manage distractions, improve reading comprehension, and structure time effectively. Offer tips on minimizing procrastination, and build in short, clear milestones to keep me on track.
        """
    }

    // #12 Assignment strategy prompt for both ADHD and Dyslexia
    static func bothAssignmentStrategy(title: String, dueDate: String, details: String) -> String {
        return """
        🔴 I have an assignment titled "\(title)" which is due on \(dueDate). The assignment details are as follows: \(details).
        
        You are helping a student with both ADHD and Dyslexia. Break down the task into simple, concise steps, making sure to reduce reading demands by using tools such as text-to-speech software or audiobooks. Provide strategies for focus, such as working in short, timed bursts, and suggest taking frequent breaks. Encourage the student to use visual aids, such as charts or color coding, to organize the steps and stay focused on deadlines.
        """
    }

    // #13 Motivational message for both ADHD and Dyslexia
    static let bothMotivationalPrompt = """
        🔴 Provide a motivational message that recognizes the challenges of managing both ADHD and Dyslexia. Encourage the student to use their strengths, such as creativity and problem-solving, to approach tasks. Remind them that they can take small steps toward success, and emphasize the importance of using tools like timers, reading aids, and breaks to stay on track. Help them visualize the satisfaction of completing each step, and remind them that they are capable of achieving their goals.
    """

    // ---------------------------------------
    // SECTION 4: Prompts for None (Honor Student)
    // ---------------------------------------
    
    // #14 Prompt used in `ImportSyllabusView.swift` and `CourseDetailView.swift for honor student`
    static func noneSyllabusAnalysisPrompt(syllabusText: String) -> String {
        return """
        🟡 Please summarize the following syllabus in an outline format with bullet points.
        Focus on the number of textbooks required, the number of units, assignments, and any key objectives or important information.

        Here is the syllabus: \(syllabusText)

        After summarizing, provide tips for efficient time management and organization. Include a motivational message that encourages the student to stay disciplined, organized, and ahead of their workload while maintaining a healthy work-life balance.
        """
    }

    // #15 Crisis plan prompt for none (honor student)
    static func noneCrisisPlanPrompt(userInput: String, allAssignments: [String], allSyllabuses: [String]) -> String {
        let assignmentsSummary = allAssignments.joined(separator: "\n")
        let syllabusSummary = allSyllabuses.joined(separator: "\n")
        
        return """
        🟡 I am a student with no diagnosed learning difficulties, but I am feeling overwhelmed by my workload. Here's what's going on: "\(userInput)".
        
        Below are the key details from my assignments:
        \(assignmentsSummary)
        
        Syllabus details:
        \(syllabusSummary)
        
        Provide a well-structured plan that focuses on time management, task prioritization, and balancing workload effectively. The plan should break larger tasks into manageable steps and suggest methods for optimizing study sessions and reducing unnecessary stress. Include tips on maximizing productivity without sacrificing mental and physical well-being.
        """
    }

    //  #16 Assignment strategy prompt for none (honor student)
    static func noneAssignmentStrategy(title: String, dueDate: String, details: String) -> String {
        return """
        🟡 I have an assignment titled "\(title)" which is due on \(dueDate). The assignment details are as follows: \(details).
        
        Please provide a well-organized, step-by-step plan to complete this assignment efficiently. Focus on using effective time management techniques, breaking the assignment into smaller sections with clear deadlines, and balancing academic work with other responsibilities. Provide strategies for staying ahead of schedule and avoiding last-minute stress.
        """
    }

    // #17 Motivational message for none (honor student)
    static let noneMotivationalPrompt = """
        🟡 Provide a motivational message that encourages the student to continue excelling. Emphasize their strengths in organization, time management, and focus, while reminding them that staying disciplined and maintaining a healthy balance between academic work and personal life will help them reach their goals with ease and confidence.
    """
}

// ---------------------------------------
// SECTION 1: Prompts for ADHD
// ---------------------------------------
// 🔵 1. ADHD Syllabus Analysis Prompt – adhdSyllabusAnalysisPrompt
// 🔵 2. Crisis Plan Prompt for ADHD – crisisPlanPrompt
// 🔵 3. Assignment Strategy Prompt for ADHD – assignmentStrategy
// 🔵 4. Assignment Strategy with Feedback for ADHD – assignmentStrategyWithFeedback
// 🔵 5. Motivational Message for ADHD – motivationalPrompt

// ---------------------------------------
// SECTION 2: Prompts for Dyslexia
// ---------------------------------------
// 🟢 6. Dyslexia Syllabus Analysis Prompt – dyslexiaSyllabusAnalysisPrompt
// 🟢 7. Crisis Plan Prompt for Dyslexia – dyslexiaCrisisPlanPrompt
// 🟢 8. Assignment Strategy Prompt for Dyslexia – dyslexiaAssignmentStrategy
// 🟢 9. Motivational Message for Dyslexia – dyslexiaMotivationalPrompt

// ---------------------------------------
// SECTION 3: Prompts for Both ADHD and Dyslexia
// ---------------------------------------
// 🔴 10. Both ADHD and Dyslexia Syllabus Analysis Prompt
