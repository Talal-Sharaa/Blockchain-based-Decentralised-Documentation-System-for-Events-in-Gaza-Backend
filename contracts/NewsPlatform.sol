// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract NewsPlatform is AccessControl {
    bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PUBLISHER_ROLE, msg.sender);
    }

    event ArticleSubmitted(address publisher, uint256 articleId);
    event ArticleUpdated(uint256 articleId);

    modifier onlyPublisher() {
        require(hasRole(PUBLISHER_ROLE, msg.sender), "Caller is not a publisher");
        _;
    }

    struct Publisher {
        address publisherID;
        uint256 registrationTimestamp;
        int256 reputationScore;
        bool isRegistered;
    }

    struct ArticleVersion {
        uint256 versionNumber;
        string articleHash;
        address editorID;
        uint256 editTimestamp;
        string title;
        string content;
    }

    struct Article {
        string title;
        string content;
        uint256 timestamp;
        address publisherID;
        string articleHash;
        mapping(uint256 => ArticleVersion) versionHistory;
    }

    struct ArticlewithOutVersion {
        uint256 id;
        string title;
        string content;
        uint256 timestamp;
        address publisherID;
        string articleHash;
    }

    struct ArticleWithID {
        uint256 id;
        string title;
        string content;
        uint256 timestamp;
        address publisherID;
        string articleHash;
    }

    mapping(address => string) public publisherNames;
    mapping(uint256 => Article) public articles;
    mapping(uint256 => ArticlewithOutVersion) public articleVersionless;
    mapping(address => Publisher) public publishers;
    mapping(address => uint256[]) public publisherArticles;
    mapping(string => address) public nameToPublisherAddress;
    uint256 private articleIdCounter;
    mapping(uint256 => uint256) public articleVersionCounts;

    address[] public publisherAddresses;
    struct Reader {
        address readerID;
    }
   
    mapping(address => Reader) public readers;

   
    
    function isAdmin(address user) public view returns (bool) {
    return hasRole(DEFAULT_ADMIN_ROLE, user);
}
    function isPublisher(address user) public view returns (bool) {
    return hasRole(PUBLISHER_ROLE, user);
}
    
function getAllPublishers() public view returns (Publisher[] memory) {
    uint256 totalPublishers = 0;

    // Count total registered publishers
    for (uint i = 0; i < publisherAddresses.length; i++) {
        address publisherAddr = publisherAddresses[i];
        if (publishers[publisherAddr].isRegistered) {
            totalPublishers++;
        }
    } 

    // Create an array to store publishers
    Publisher[] memory allPublishers = new Publisher[](totalPublishers);

    // Add registered publishers to the array
    uint256 index = 0;
    for (uint i = 0; i < publisherAddresses.length; i++) {
        address publisherAddr = publisherAddresses[i];
        if (publishers[publisherAddr].isRegistered) {
            allPublishers[index] = publishers[publisherAddr];
            index++;
        }
    }

    return allPublishers;
}
function getAllArticles() public view returns (ArticleWithID[] memory) {
        uint256 totalArticles = articleIdCounter;
        ArticleWithID[] memory allArticles = new ArticleWithID[](totalArticles);

        for (uint256 i = 1; i <= totalArticles; i++) {
            allArticles[i - 1] = getArticle(i);
        }

        return allArticles;
    }

function getAllArticleIds() public view returns (uint256[] memory) {
    uint256 totalArticles = articleIdCounter;
    uint256[] memory allArticleIds = new uint256[](totalArticles);

    for (uint256 i = 1; i <= totalArticles; i++) {
        allArticleIds[i - 1] = i;
    }

    return allArticleIds;
}
    // ... other functions ...
    function grantAdminRole(address newAdmin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
    }
  function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        return string(abi.encodePacked(_bytes32));
    }

    function registerPublisher(address publisherAddress, string memory name) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        require(!publishers[publisherAddress].isRegistered, "Publisher already registered");
       publishers[publisherAddress] = Publisher({
        publisherID: publisherAddress,
        registrationTimestamp: block.timestamp,
        reputationScore: 0,
        isRegistered: true
    });
    // Add the new publisher's address to publisherAddresses
    publisherAddresses.push(publisherAddress);
    publisherNames[publisherAddress] = name; // Store the publisher's name
    nameToPublisherAddress[name] = publisherAddress; // Add this line

    grantRole(PUBLISHER_ROLE, publisherAddress);
}

  function getArticlesByName(string memory name) public view returns (ArticleWithID[] memory) {
        address publisherAddress = nameToPublisherAddress[name];
        require(publisherAddress != address(0), "Publisher not found");
        return getArticlesByPublisher(publisherAddress);
    }
    // Add this state variable to your contract
    function submitArticle(string memory title, string memory content) public onlyPublisher {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(content).length > 0, "Content cannot be empty");

        articleIdCounter++;
        uint256 articleId = articleIdCounter;

        bytes32 articleHash = keccak256(abi.encodePacked(title, content));

        articles[articleId].title = title;
        articles[articleId].content = content;
        articles[articleId].timestamp = block.timestamp;
        articles[articleId].publisherID = msg.sender;
        articles[articleId].articleHash = bytes32ToString(articleHash);

        uint256 initialVersion = 1;
        articles[articleId].versionHistory[initialVersion] = ArticleVersion({
            versionNumber: initialVersion,
            articleHash: bytes32ToString(articleHash),
            editorID: msg.sender,
            editTimestamp: block.timestamp,
            title: title,
            content: content
        });

        // Increment the version count for the article
        articleVersionCounts[articleId] = initialVersion;

        publisherArticles[msg.sender].push(articleId);

        // Add the article to the versionless mapping
        articleVersionless[articleId] = ArticlewithOutVersion({
            id: articleId,
            title: title,
            content: content,
            timestamp: block.timestamp,
            publisherID: msg.sender,
            articleHash: bytes32ToString(articleHash)
        });
                emit ArticleSubmitted(msg.sender, articleId);

    }

function updateArticle(uint256 articleId, string memory newTitle, string memory newContent) public {
    // Check if the article exists
    require(articles[articleId].timestamp != 0, "Article does not exist");

    // Check if the sender is the publisher of the article
    require(msg.sender == articles[articleId].publisherID, "Only the publisher can update the article");

    // Check if the new title and content are not empty
    require(bytes(newTitle).length > 0, "New title cannot be empty");
    require(bytes(newContent).length > 0, "New content cannot be empty");

    // Compute the hash of the new content
    bytes32 newArticleHash = keccak256(abi.encodePacked(newTitle, newContent));

    // Update the article
    articles[articleId].title = newTitle;
    articles[articleId].content = newContent;
    articles[articleId].articleHash = bytes32ToString(newArticleHash);

    // Add a new version
    uint256 newVersionNumber = articleVersionCounts[articleId] + 1;
    articles[articleId].versionHistory[newVersionNumber] = ArticleVersion({
        versionNumber: newVersionNumber,
        articleHash: bytes32ToString(newArticleHash),
        editorID: msg.sender,
        editTimestamp: block.timestamp,
        title: newTitle,
        content: newContent
    });

    // Update the version count for the article
    articleVersionCounts[articleId] = newVersionNumber;

    // Update the article in the versionless mapping
    articleVersionless[articleId] = ArticlewithOutVersion({
        id: articleId,
        title: newTitle,
        content: newContent,
        timestamp: block.timestamp,
        publisherID: msg.sender,
        articleHash: bytes32ToString(newArticleHash)
    });

    // Emit the ArticleUpdated event AFTER the update is successful
    emit ArticleUpdated(articleId);
}
function getArticleHistory(uint256 articleId) public view returns (ArticleVersion[] memory) {
    // Check if the article exists
    require(articles[articleId].timestamp != 0, "Article does not exist");

    // Get the number of versions
    uint256 numberOfVersions = articleVersionCounts[articleId];

    // Create an array to store the versions
    ArticleVersion[] memory history = new ArticleVersion[](numberOfVersions);

    // Get the versions
      for (uint256 i = 1; i <= numberOfVersions; i++) { 
        history[i - 1] = articles[articleId].versionHistory[i];
    }


    // Return the versions
    return history;
}
 function getArticle(uint256 articleId) public view returns (ArticleWithID memory) {
        require(articleVersionless[articleId].timestamp != 0, "Article does not exist");
        return ArticleWithID({
            id: articleId,
            title: articleVersionless[articleId].title,
            content: articleVersionless[articleId].content,
            timestamp: articleVersionless[articleId].timestamp,
            publisherID: articleVersionless[articleId].publisherID,
            articleHash: articleVersionless[articleId].articleHash
        });
    }

 function getArticlesByPublisher(address publisherAddress) public view returns (ArticleWithID[] memory) {
        require(publishers[publisherAddress].isRegistered, "Publisher not registered");

        uint256[] memory articleIds = publisherArticles[publisherAddress];
        ArticleWithID[] memory articlesByPublisher = new ArticleWithID[](articleIds.length);

        for (uint256 i = 0; i < articleIds.length; i++) {
            articlesByPublisher[i] = getArticle(articleIds[i]);
        }

        return articlesByPublisher;
    }


// Inside your NewsPlatform contract
mapping(address => uint256[]) public userFavorites; // Maps user addresses to an array of their favorite article IDs

// Function to add an article to favorites
function addToFavorites(uint256 articleId) public {
    require(articles[articleId].timestamp != 0, "Article does not exist");
    userFavorites[msg.sender].push(articleId); 
}

// Function to remove an article from favorites
function removeFromFavorites(uint256 articleId) public {
    uint256[] storage favorites = userFavorites[msg.sender];
    for (uint256 i = 0; i < favorites.length; i++) {
        if (favorites[i] == articleId) {
            favorites[i] = favorites[favorites.length - 1]; // Move the last element to the position of the deleted element
            favorites.pop(); // Decrease the array's length by one
            break;
        }
    }
}
// Function to retrieve a user's favorite articles
function getFavorites() public view returns (ArticleWithID[] memory) {
    uint256[] memory favoriteIds = userFavorites[msg.sender];
    ArticleWithID[] memory favoriteArticles = new ArticleWithID[](favoriteIds.length);

    for (uint256 i = 0; i < favoriteIds.length; i++) {
        favoriteArticles[i] = getArticle(favoriteIds[i]);
    }

    return favoriteArticles;
}

}
