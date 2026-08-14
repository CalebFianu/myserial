package com.myserial.domain.repository;

import com.myserial.domain.entity.ListCollaborator;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ListCollaboratorRepository extends JpaRepository<ListCollaborator, Long> {
    List<ListCollaborator> findByListId(Long listId);
    boolean existsByListIdAndUserId(Long listId, Long userId);
}
