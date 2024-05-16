
**Title:** Blockchain-based Decentralised Documentation System for Events in Gaza

**Description:** A decentralized, censorship-resistant news platform built on the Ethereum blockchain, ensuring the integrity and transparency of news reporting.

**Technologies Used**

-   Blockchain: Ethereum (Sepolia Testnet)
-   Smart Contract Language: Solidity
-   OpenZeppelin Contracts (for access control)
-   (If applicable) Web Framework: (e.g., React, Next.js)

**Problem and Solution**

-   The abundance of news sources makes it difficult to discern reliable, unbiased information. Centralized news platforms are susceptible to censorship and manipulation.
-   TrustNews offers a blockchain-based solution where news articles are immutably stored, ensuring their accuracy and preventing unauthorized alterations. News is secured, and its history of changes is traceable.

**Features**

-   **Decentralized Storage:** News articles are stored on the Ethereum blockchain, promoting transparency and combating censorship.
-   **Publisher Traceability:** Publishers build a reputation on the platform, held accountable for the news they share. Publishers can distribute their content while maintaining their ownership of the content.
-   **Reader Confidence:** Readers know that the articles they access are authentic and have not been tampered with.
-   **Smart Contracts:** Automated permission management for publishers and readers, using AccessControl for role-based authorization.
-   **Article Versioning:** Tracks the history of edits to an article, ensuring full transparency for readers.
-   **User Favorites:** Readers can bookmark and organize preferred articles.

**Smart Contract Highlights**

(Here I'll provide a breakdown of key functions and data structures, with your comments added as needed)

-   **AccessControl** (from OpenZeppelin): Enforces role-based permissions for admins and publishers.
-   **Publisher struct:** Stores essential publisher information (address, registration timestamp, reputation score).
-   **Article struct:** Stores core article data (title, content, timestamp, publisherID, articleHash) along with version history.
-   **submitArticle()**: Enables publishers to submit new articles which are cryptographically hashed for integrity checks. Adds new versions to the history.
-   **updateArticle()**: Allows the original publisher to update an article's title and content while maintaining its edit history.
-   **getArticle()**: Retrieves the latest version of an article.
-   **getArticleHistory()**: Provides the complete edit history of an article for full transparency.
-   **addToFavorites() / removeFromFavorites() / getFavorites()**: Allows users to curate their own list of preferred articles.

**Getting Started**

-   **Prerequisites:**
    
    -   Node.js
    -   MetaMask wallet
    -   (Optional) Web3.js for interacting with front-end
    
-   **Installation:**
    
    -   `git clone https://github.com/your-username/TrustNews.git`
    -   `npm install`
    
-   **Deployment:**
    
npx hardhat run scripts/deploy.js --network sepolia    

**How to Use**

-   **Publishers:**
    
    -   Request publisher role or gain it at platform launch.
    -   Submit news articles using `submitArticle()`.
    -   Responsibly update articles when necessary with `updateArticle()`.
    
-   **Readers:**
    
    -   Access the news feed and view articles guaranteed to be untampered with.
    -   Use `getArticleHistory()` to verify past versions if desired.
    -   Manage your favorite articles with the favorites functions.
    
**License**

MIT License

**Acknowledgements**

-   OpenZeppelin for secure smart contract templates.

**Let's Build Trust in News**
